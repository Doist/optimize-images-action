# GitHub Action: Optimize Images

GitHub Action that applies lossless image optimization.

## Usage

```yaml
- uses: doist/optimize-images-action
  with:
    # Colon-delimited list of files and directories to process, e.g., "assets".
    input: "**/*"
    # Colon-delimited list of files and directories to ignore, e.g., "store:assets/originals".
    ignore: ""
```

The values shown are the defaults.

## Acknowledgements

This action builds upon the excellent [image_optim](https://github.com/toy/image_optim) by [@toy](https://github.com/toy).

## License

[MIT License](https://github.com/Doist/optimize-images-action/blob/main/LICENSE).
