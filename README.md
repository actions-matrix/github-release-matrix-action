## About

GitHub Action to generate matrix from GitHub's repository releases via GitHub API.


## Usage

You can now consume the action by referencing the `v1` branch

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
**Example screenshot**

<img width="100%" alt="Screenshot 2024-04-30 at 8 39 46 in the evening" src="https://github.com/actions-matrix/github-release-matrix-action/assets/4363857/269a8f60-0575-4408-b4dc-ce5363683795">

## Inputs

- `repository`: Repository owner/name (e.g. "octocat/Hello-World")'
- `release`: Release filter (e.g. "latest", "*"). (Default: "*")'
- `prerelease`: Include prerelease releases. (Default: false)'
- `prefix`: Remove version prefix from release tag name. (Default: false)'
- `limit`: Limit the number of releases to fetch. (Default: 3)'

## Outputs

- `matrix`: JSON string with the matrix of releases.

**Example**

```json
{
  "releases": [
    {
      "tag_name": "v1.16.2",
      "target_commitish": "c6e4c2d4dc3b0d57791881b087c026e2f75a87cb",
      "author": "hc-github-team-es-release-engineering",
      "created_at": "2024-04-22T20:25:54Z",
      "published_at": "2024-04-23T21:51:34Z"
    }
  ]
}
```

## License
Licensed under the [MIT License](LICENSE).
