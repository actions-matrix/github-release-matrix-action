
#!/bin/bash
set -e

echo ""
echo "!!! DISCLAIMER !!!"
echo "------------------------------------------------------------------------------"
echo "This action uses the GitHub API to fetch release information."
echo "To avoid unnecessary and straining the GitHub REST API servers,"
echo "Please consider limit the number of uses of this action."
echo "------------------------------------------------------------------------------"
echo ""

# Action input variables
INPUT_REPOSITORY=${1}
INPUT_RELEASE=${2:-"*"}
INPUT_PRERELEASE=${3:-"false"}
INPUT_PREFIX=${4:-"false"}
INPUT_LIMIT=${5:-"3"}

if [[ -z "${INPUT_REPOSITORY}" ]]; then
	echo "::error::Missing required 'repository' input"
	exit 1
fi

# Private variables
X_GITHUB_API_VERSION="2022-11-28"
X_GITHUB_RELEASE_API_URL="/repos/${INPUT_REPOSITORY}/releases"
X_JQ_RELEASE_QUERY="{tag_name, target_commitish, author: .author.login, created_at, published_at}"

if [[ "$INPUT_RELEASE" == "latest" ]]; then
	X_GITHUB_RELEASE_API_URL="${X_GITHUB_RELEASE_API_URL}/latest"
else
	X_JQ_RELEASE_QUERY=".[] | ${X_JQ_RELEASE_QUERY}"
fi

echo "Querying GitHub releases for \"$INPUT_REPOSITORY\" repository..."
echo " - Repository: $INPUT_REPOSITORY"
echo " - Selector: $INPUT_RELEASE"
echo " - Include prerelease: $INPUT_PRERELEASE"
echo " - Trim prefix: $INPUT_PREFIX"
echo " - Limit: $INPUT_LIMIT"

mkdir -p "$RUNNER_TEMP/$INPUT_REPOSITORY"
GITHUB_RELEASE_MATRIX_ACTION_RAW_RELEASE_FILE="$RUNNER_TEMP/$INPUT_REPOSITORY/releases.json"
GITHUB_RELEASE_MATRIX_ACTION_RELEASE_FILE="$RUNNER_TEMP/$INPUT_REPOSITORY/releases-filtered.json"
gh api --paginate \
	-H "Accept: application/vnd.github+json" \
	-H "X-GitHub-Api-Version: ${X_GITHUB_API_VERSION}" \
	"$X_GITHUB_RELEASE_API_URL" \
	> "$GITHUB_RELEASE_MATRIX_ACTION_RAW_RELEASE_FILE"

cat "$GITHUB_RELEASE_MATRIX_ACTION_RAW_RELEASE_FILE" |
	jq "if \"$INPUT_RELEASE\" == \"*\" then map(select(.draft == false and .prerelease == $INPUT_PRERELEASE)) else . end" |
	jq "$X_JQ_RELEASE_QUERY" |
	jq "if ($INPUT_PREFIX) then .tag_name |= ltrimstr(\"v\") else . end" |
	jq --slurp "." |
	jq "if $INPUT_LIMIT < 0 then . else .[:$INPUT_LIMIT] end" |
	jq --raw-output "tostring" \
	> "$GITHUB_RELEASE_MATRIX_ACTION_RELEASE_FILE"

echo ""
echo "Exporting environment variables:"
echo "GITHUB_RELEASE_MATRIX_ACTION_RAW_RELEASE_FILE=${GITHUB_RELEASE_MATRIX_ACTION_RAW_RELEASE_FILE}" | tee -a "${GITHUB_ENV}"
echo "GITHUB_RELEASE_MATRIX_ACTION_RELEASE_FILE=${GITHUB_RELEASE_MATRIX_ACTION_RELEASE_FILE}" | tee -a "${GITHUB_ENV}"

echo ""
echo "Configure output variables:"
echo "------------------------------------------------------------------------------"
echo "matrix={\"releases\": $(cat "$GITHUB_RELEASE_MATRIX_ACTION_RELEASE_FILE")}" | tee -a "$GITHUB_OUTPUT"
echo "------------------------------------------------------------------------------"
