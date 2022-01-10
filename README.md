# GitHub Action: Optimize Images

GitHub Action that applies lossless image optimization.

## Usage

```yaml
- uses: doist/optimize-images-action@v2
  with:
    # Colon-delimited list of files and directories to process, e.g., "assets".
    input: "**/*"
    # Colon-delimited list of files and directories to ignore, e.g., "store:assets/originals".
    ignore: ""
```

The values shown are the defaults. For paths, glob patterns using `*`, `**` and `?` are supported.

## Examples

Here's a workflow that optimizes images when they change on the main branch, and submits a pull request with the changes:

```yaml
name: Optimize images and PR

on:
  push:
    branches:
      - main
    paths:
      - "**.png"
      - "**.jpe?g"
      - "**.svg"
      - "**.gif"

jobs:
  optimize-images:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2 
      - name: Optimize images
        id: optimize-images
        uses: Doist/optimize-images-action@v2
      - name: Create pull request
        uses: peter-evans/create-pull-request@v3
        with:
          commit-message: "Optimize images (lossless)"
          delete-branch: true
          body: ${{ steps.optimize-images.outputs.summary }}
```

Or one that optimizes images included in a pull request to the main branch and commits the changes:

```yaml
name: Optimize images and commit

on:
  pull_request:
    branches:
      - main
    paths:
      - "**.png"
      - "**.jpe?g"
      - "**.svg"
      - "**.gif"

jobs:
  optimize-images:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2 
      - name: Optimize images
        uses: Doist/optimize-images-action@v2
      - name: Commit
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "Optimize images (lossless)"
```

## Acknowledgements

This action builds upon the excellent [image_optim](https://github.com/toy/image_optim) by [@toy](https://github.com/toy).

## License

[MIT License](https://github.com/Doist/optimize-images-action/blob/main/LICENSE).
