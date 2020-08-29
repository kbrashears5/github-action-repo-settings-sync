#!/bin/bash

echo "Repository: [$GITHUB_REPOSITORY]"

# log inputs
echo "Inputs"
echo "---------------------------------------------"
RAW_REPOSITORIES="$INPUT_REPOSITORIES"
REPOSITORIES=($RAW_REPOSITORIES)
echo "Repositories    : $REPOSITORIES"
ALLOW_ISSUES=($INPUT_ALLOW_ISSUES)
echo "Allow Issues    : $ALLOW_ISSUES"
ALLOW_PROJECTS=($INPUT_ALLOW_PROJECTS)
echo "Allow Projects  : $ALLOW_PROJECTS"
ALLOW_WIKI=($INPUT_ALLOW_WIKI)
echo "Allow Wiki      : $ALLOW_WIKI"
SQUASH_MERGE=($INPUT_SQUASH_MERGE)
echo "Squash Merge    : $SQUASH_MERGE"
MERGE_COMMIT=($INPUT_MERGE_COMMIT)
echo "Merge Commit    : $MERGE_COMMIT"
REBASE_MERGE=($INPUT_REBASE_MERGE)
echo "Rebase Merge    : $REBASE_MERGE"
DELETE_HEAD=($INPUT_DELETE_HEAD)
echo "Delete Head     : $DELETE_HEAD"
GITHUB_TOKEN="$INPUT_TOKEN"
echo "---------------------------------------------"

echo " "

# set temp path
TEMP_PATH="/ghars/"
cd /
mkdir "$TEMP_PATH"
cd "$TEMP_PATH"
echo "Temp Path       : $TEMP_PATH"

echo " "

# find username and repo name
REPO_INFO=($(echo $GITHUB_REPOSITORY | tr "/" "\n"))
USERNAME=${REPO_INFO[0]}
echo "Username: [$USERNAME]"

echo " "

# get all repos, if specified
if [ "$REPOSITORIES" == "ALL" ]; then
    echo "Getting all repositories for ${USERNAME}"
    REPOSITORIES=$(curl -X GET -H "Accept: application/vnd.github.v3+json" -u ${USERNAME}:${GITHUB_TOKEN} --silent ${GITHUB_API_URL}/users/${USERNAME}/repos | jq '.[].full_name')
fi

# loop through all the repos
for repository in "${REPOSITORIES[@]}"; do
    echo "###[group] $repository"

    echo "Repository name: [$repository]"

    echo " "
  
    jq -n \
    --arg allowIssues "$ALLOW_ISSUES" \
    --arg allowProjects "$ALLOW_PROJECTS" \
    --arg allowWiki "$ALLOW_WIKI" \
    --arg squashMerge "$SQUASH_MERGE" \
    --arg mergeCommit "$MERGE_COMMIT" \
    --arg rebaseMerge "$REBASE_MERGE" \
    --arg deleteHead "$DELETE_HEAD" \
    '{
        has_issues:$allowIssues,
        has_projects:$allowProjects,
        has_wiki:$allowWiki,
        allow_squash_merge:$squashMerge,
        allow_merge_commit:$mergeCommit,
        allow_rebase_merge:$rebaseMerge,
        delete_branch_on_merge:$deleteHead,
    }' \
    | curl -d @- \
        -X PATCH \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -u ${USERNAME}:${GITHUB_TOKEN} \
        --silent \
        ${GITHUB_API_URL}/repos/${repository}

    echo " "
    
    echo "Completed [${repository}]"
    echo "###[endgroup]"
done