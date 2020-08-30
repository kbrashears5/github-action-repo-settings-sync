#!/bin/bash

echo "Repository: [$GITHUB_REPOSITORY]"

# log inputs
echo "Inputs"
echo "---------------------------------------------"
RAW_REPOSITORIES="$INPUT_REPOSITORIES"
REPOSITORIES=($RAW_REPOSITORIES)
echo "Repositories           : $REPOSITORIES"
ALLOW_ISSUES=$INPUT_ALLOW_ISSUES
echo "Allow Issues           : $ALLOW_ISSUES"
ALLOW_PROJECTS=$INPUT_ALLOW_PROJECTS
echo "Allow Projects         : $ALLOW_PROJECTS"
ALLOW_WIKI=$INPUT_ALLOW_WIKI
echo "Allow Wiki             : $ALLOW_WIKI"
SQUASH_MERGE=$INPUT_SQUASH_MERGE
echo "Squash Merge           : $SQUASH_MERGE"
MERGE_COMMIT=$INPUT_MERGE_COMMIT
echo "Merge Commit           : $MERGE_COMMIT"
REBASE_MERGE=$INPUT_REBASE_MERGE
echo "Rebase Merge           : $REBASE_MERGE"
DELETE_HEAD=$INPUT_DELETE_HEAD
echo "Delete Head            : $DELETE_HEAD"
BRANCH_PROTECTION_NAME=$INPUT_BRANCH_PROTECTION_NAME
echo "Branch Protection Name : $BRANCH_PROTECTION_NAME"
BRANCH_PROTECTION_REQUIRED_REVIEWERS=$INPUT_BRANCH_PROTECTION_REQUIRED_REVIEWERS
echo "Required Reviewers     : $BRANCH_PROTECTION_REQUIRED_REVIEWERS"
BRANCH_PROTECTION_DISMISS=$INPUT_BRANCH_PROTECTION_DISMISS
echo "Dismiss Stale          : $BRANCH_PROTECTION_DISMISS"
BRANCH_PROTECTION_CODE_OWNERS=$INPUT_BRANCH_PROTECTION_CODE_OWNERS
echo "Code Owners            : $BRANCH_PROTECTION_CODE_OWNERS"
BRANCH_PROTECTION_ENFORCE_ADMINS=$INPUT_BRANCH_PROTECTION_ENFORCE_ADMINS
echo "Code Owners            : $BRANCH_PROTECTION_ENFORCE_ADMINS"
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
    echo "Getting all repositories for [${USERNAME}]"
    REPOSITORIES_STRING=$(curl -X GET -H "Accept: application/vnd.github.v3+json" -u ${USERNAME}:${GITHUB_TOKEN} --silent ${GITHUB_API_URL}/users/${USERNAME}/repos | jq '.[].full_name')
    readarray -t REPOSITORIES <<< "$REPOSITORIES_STRING"
fi

# loop through all the repos
for repository in "${REPOSITORIES[@]}"; do
    echo "###[group] $repository"

    # trim the quotes
    repository="${repository//\"}"

    echo "Repository name: [$repository]"

    echo " "

    echo "Setting repository options"
  
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

    echo "Setting [${BRANCH_PROTECTION_NAME}] branch protection rules"
    
    jq -n \
    --arg enforceAdmins "$BRANCH_PROTECTION_ENFORCE_ADMINS" \
    --arg dismissStaleReviews "$BRANCH_PROTECTION_DISMISS" \
    --arg codeOwnerReviews "$BRANCH_PROTECTION_CODE_OWNERS" \
    --arg reviewCount "$BRANCH_PROTECTION_REQUIRED_REVIEWERS" \
    '{
        enforce_admins:$enforceAdmins,
        required_pull_request_reviews:{
            dismiss_stale_reviews:$dismissStaleReviews,
            require_code_owner_reviews:$codeOwnerReviews,
            required_approving_review_count:$reviewCount
        }
    }' \
    | curl -d @- \
        -X PUT \
        -H "Accept: application/vnd.github.luke-cage-preview+json" \
        -H "Content-Type: application/json" \
        -u ${USERNAME}:${GITHUB_TOKEN} \
        --silent \
        ${GITHUB_API_URL}/repos/${repository}/branches/${BRANCH_PROTECTION_NAME}/protection

    echo "Completed [${repository}]"
    echo "###[endgroup]"
done