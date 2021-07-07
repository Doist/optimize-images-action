#!/usr/bin/env ruby

require 'getoptlong'
require 'shellwords'
require 'image_optim'
require 'image_optim/space'

def percent(old_size, new_size)
    return format("%.2f%%", 100 - 100.0 * new_size / old_size)
end

def file_size(size)
    return ImageOptim::Space.space(size).strip()
end

def line(name, old_size, new_size)
    return "| #{name} | #{file_size(old_size)} | #{file_size(new_size)} | #{percent(old_size, new_size)} |"
end

# Setup user options.
opts = {
    '--input' => Dir.glob('**/*'),
    '--min-files' => 1,
    '--min-size' => 1,
    '--ignore' => []
}

GetoptLong.new(*opts.map { |o| [o[0], GetoptLong::OPTIONAL_ARGUMENT] }).each do |name, value|
    next if value.empty?
    if opts[name].kind_of?(Array)
        opts[name] = value.shellsplit
    else
        opts[name] = value.to_i
    end
end

# Setup ImageOptim options.
image_optim = ImageOptim.new(
    :advpng => {
        :level => 3
    },
    :pngout => false,
    :svgo => {
        :enable_plugins => [
            # Lossless according to ImageOptim:
            # https://github.com/ImageOptim/ImageOptim/blob/4fabd939a395ebcfb78e3d57aed6c782a530793a/svgo/index.js#L6-L23
            'cleanupAttrs', 'cleanupListOfValues', 'cleanupNumericValues', 'convertColors', 'convertStyleToAttrs',
            'inlineStyles', 'minifyStyles', 'moveGroupAttrsToElems', 'removeComments', 'removeDoctype',
            'removeEditorsNSData', 'removeEmptyAttrs', 'removeEmptyContainers', 'removeEmptyText',
            'removeNonInheritableGroupAttrs', 'removeXMLProcInst', 'sortAttrs'
        ],
        :disable_plugins => [
            # Lossy according to ImageOptim:
            # https://github.com/ImageOptim/ImageOptim/blob/master/svgo/index.js#L25-L51
            'addAttributesToSVGElement', 'addClassesToSVGElement', 'cleanupEnableBackground', 'cleanupIDs',
            'collapseGroups', 'convertPathData', 'convertShapeToPath', 'convertTransform', 'mergePaths',
            'moveElemsAttrsToGroup', 'prefixIds', 'removeAttributesBySelector', 'removeAttrs', 'removeDesc',
            'removeDimensions', 'removeElementsByAttr', 'removeHiddenElems', 'removeMetadata', 'removeOffCanvasPaths',
            'removeRasterImages', 'removeScriptElement', 'removeStyleElement', 'removeTitle',
            'removeUnknownsAndDefaults', 'removeUnusedNS', 'removeUselessDefs', 'removeUselessStrokeAndFill',
            'removeViewBox', 'removeXMLNS'
        ]
    }
)

# Setup paths to include.
paths = opts['--input'].select { |f| File.file?(f) }.reject { |f| f.start_with?(*opts['--ignore']) }

results = ['| File | Original size | Optimized size | Reduction |', '| --- | --- | --- | --- |']
old_size = 0
new_size = 0

image_optim.optimize_images!(paths) do |_, optimized|
    next unless optimized

    results << line(optimized, optimized.original_size, optimized.size)
    old_size += optimized.original_size
    new_size += optimized.size
end

# Output results.
if results.size >= 2 + opts['--min-files'] && old_size - new_size >= opts['--min-size']
    results << "| **Total** | **#{file_size(old_size)}** | **#{file_size(new_size)}** | **#{percent(old_size, new_size)}** |"
    puts results
end
