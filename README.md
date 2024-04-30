## About

GitHub Action to generate matrix from GitHub's repository releases via GitHub API.


## Usage

```yaml
on:
  push:
    branches: [ main ]

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - id: releases
        uses: actions-matrix/github-release-matrix-action@main
        with:
          repository: "prometheus/alertmanager"
        env:
          GH_TOKEN: ${{ github.token }}
    outputs:
      matrix: ${{ steps.releases.outputs.matrix }}

  matrix:
    runs-on: ubuntu-latest
    needs: generate
    strategy:
      matrix: ${{ fromJson(needs.generate.outputs.matrix) }}
    steps:
      - run: |
          echo "tag_name=${{ matrix.releases.tag_name }}"
          echo "target_commitish=${{ matrix.releases.target_commitish }}"
          echo "author=${{ matrix.releases.author }}"
```
