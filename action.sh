
#!/bin/bash
set -e

# Action input variables
INPUT_REPOSITORY=${1}
INPUT_RELEASE=${2:-"*"}
INPUT_DRAFT=${3:-"false"}
INPUT_PRERELEASE=${4:-"false"}
INPUT_PREFIX=${5:-"false"}
INPUT_LIMIT=${6:-"3"}

if [[ -z "${INPUT_REPOSITORY}" ]]; then
    echo "::error::Missing required 'repository' input"
    exit 1
fi

# Private variables
X_GITHUB_API_VERSION="2022-11-28"
X_GITHUB_RELEASE_API_URL="/repos/${INPUT_REPOSITORY}/releases"
X_JQ_RELEASE_QUERY="{tag_name, target_commitish, draft, prerelease, created_at, published_at, author: .author.login}"

if [[ "$INPUT_RELEASE" == "latest" ]]; then
    X_GITHUB_RELEASE_API_URL="${X_GITHUB_RELEASE_API_URL}/latest"
else
    X_JQ_RELEASE_QUERY=".[] | ${X_JQ_RELEASE_QUERY}"
fi

mkdir -p "$RUNNER_TEMP/$INPUT_REPOSITORY"
gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: ${X_GITHUB_API_VERSION}" \
    "$X_GITHUB_RELEASE_API_URL" |
        jq --raw-output "$X_JQ_RELEASE_QUERY" |
        jq --raw-output "if ($INPUT_PREFIX) then .tag_name |= ltrimstr(\"v\") else . end" |
        jq --raw-output --slurp "map(select(.draft == $INPUT_DRAFT and .prerelease == $INPUT_PRERELEASE))" |
        jq --raw-output "if $INPUT_LIMIT < 0 then .[:$INPUT_LIMIT] else . end" |
        jq --raw-output "tostring" \
    > "$RUNNER_TEMP/$INPUT_REPOSITORY/releases.json"

echo "matrix={\"releases\": $(cat "$RUNNER_TEMP/$INPUT_REPOSITORY/releases.json" | jq 'tostring')}" >> "$GITHUB_OUTPUT"
