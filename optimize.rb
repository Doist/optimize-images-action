#!/usr/bin/env ruby

require 'image_optim'
require 'image_optim/space'

def expand(path)
  if File.file?(path)
    [path]
  else
    Dir.glob(path).select { |f| File.file?(f) }
  end
end

def percent(old_size, new_size)
  format("%.2f%%", 100 - 100.0 * new_size / old_size)
end

def file_size(size)
  ImageOptim::Space.space(size).strip
end

def line(name, old_size, new_size)
  "| #{name} | #{file_size(old_size)} | #{file_size(new_size)} | #{percent(old_size, new_size)} |"
end

# Setup action options.
input = ENV["INPUT"].split(File::PATH_SEPARATOR).flat_map { |path| expand(path) }
ignore = ENV["IGNORE"].split(File::PATH_SEPARATOR).flat_map { |path| expand(path) }

# Setup ImageOptim options.
image_optim = ImageOptim.new(
  :advpng => false, # redundant with oxipng
  :pngcrush => false, # redundant with oxipng
  :pngout => false, # redundant with oxipng
  :optipng => false, # redundant with oxipng
  :jpegoptim => false, # redundant with jpegrecompress
  :jpegtran => false, # redundant with jpegrecompress
  :svgo => {
    :enable_plugins => %w[
        cleanupAttrs cleanupListOfValues cleanupNumericValues convertColors convertStyleToAttrs
        inlineStyles minifyStyles moveGroupAttrsToElems removeComments removeDoctype
        removeEditorsNSData removeEmptyAttrs removeEmptyContainers removeEmptyText
        removeNonInheritableGroupAttrs removeXMLProcInst sortAttrs
    ],
    :disable_plugins => %w[
        addAttributesToSVGElement addClassesToSVGElement cleanupEnableBackground cleanupIDs
        collapseGroups convertPathData convertShapeToPath convertTransform mergePaths
        moveElemsAttrsToGroup prefixIds removeAttributesBySelector removeAttrs removeDesc
        removeDimensions removeElementsByAttr removeHiddenElems removeMetadata
        removeOffCanvasPaths removeRasterImages removeScriptElement removeStyleElement
        removeTitle removeUnknownsAndDefaults removeUnusedNS removeUselessDefs
        removeUselessStrokeAndFill removeViewBox removeXMLNS
    ]
  }
)

# Setup paths to include.
paths = input.reject { |p| ignore.any? { |i| File.identical?(i, p) } }

results = ['| File | Original size | Optimized size | Reduction |', '| --- | --- | --- | --- |']
old_size = 0
new_size = 0

image_optim.optimize_images!(paths) do |_, optimized|
  next unless optimized

  results << line(optimized, optimized.original_size, optimized.size)
  old_size += optimized.original_size
  new_size += optimized.size
end

# Output summary.
if results.size > 2
  results << line("Total", old_size, new_size)

  summary = results.join("\n")
  puts summary

  # Escape %, \n, and \r.
  # Ref: https://github.community/t/set-output-truncates-multiline-strings/16852/3
  summary.gsub!(/[%\n\r]/, "%" => "%25", "\n" => "%0A", "\r" => "%0D")
  puts "echo ':name=summary::#{summary}' >> $GITHUB_OUTPUT"
else
  puts "Nothing to optimize"
end

