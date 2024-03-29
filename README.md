# github-action-repo-settings-sync
Github Action to setup repositories settings and keep them in sync

[![version](https://img.shields.io/github/v/release/kbrashears5/github-action-repo-settings-sync)](https://img.shields.io/github/v/release/kbrashears5/github-action-repo-settings-sync)

# Use Cases
Great for keeping repository settings in sync across all repos. I constantly forget when creating new repos to go tweak all my repository settings how I like them, set up branch policies, etc. This allows me to add my new repo to the list (or just take the default of all and have no steps) and automatically have my settings there.

# Setup
Create a new file called `/.github/workflows/repo-settings-sync.yml` that looks like so:
```yaml
name: Repo Setup

on:
  push:
    branches:
      - master
  schedule:
    - cron: 0 0 * * *

jobs:
  repo_setup:
    runs-on: ubuntu-latest
    steps:
      - name: Repo Setup
        uses: kbrashears5/github-action-repo-settings-sync@v3.0.0
        with:
          REPOSITORIES: |
            kbrashears5/github-action-repo-settings-sync
          ALLOW_ISSUES: 'true'
          ALLOW_PROJECTS: 'true'
          ALLOW_WIKI: 'true'
          SQUASH_MERGE: 'true'
          MERGE_COMMIT: 'true'
          REBASE_MERGE: 'true'
          AUTO_MERGE: 'false'
          DELETE_HEAD: 'false'
          BRANCH_PROTECTION_ENABLED: 'true'
          BRANCH_PROTECTION_NAME: 'main'
          BRANCH_PROTECTION_REQUIRED_REVIEWERS: '1'
          BRANCH_PROTECTION_DISMISS: 'true'
          BRANCH_PROTECTION_CODE_OWNERS: 'true'
          BRANCH_PROTECTION_ENFORCE_ADMINS: 'false'
          TOKEN: ${{ secrets.ACTIONS }}
```
## Parameters
| Parameter | Required | Default | Description |
| --- | --- | --- | --- |
| TOKEN | __true__ |  |Personal Access Token with Repo scope |
| REPOSITORIES | false | 'ALL' | Github repositories to setup. Default will get all public repositories for your username |
| ALLOW_ISSUES | false | true | Whether or not to allow issues on the repo |
| ALLOW_PROJECTS | false | true | Whether or not to allow projects on the repo |
| ALLOW_WIKI | false | true | Whether or not to allow wiki on the repo |
| SQUASH_MERGE | false | true | Whether or not to allow squash merges on the repo |
| MERGE_COMMIT | false | true | Whether or not to allow merge commits on the repo |
| REBASE_MERGE | false | true | Whether or not to allow rebase merges on the repo |
| AUTO_MERGE | false | false | Whether or not to allow auto-merge on the repo |
| DELETE_HEAD | false | false | Whether or not to delete head branch after merges |
| BRANCH_PROTECTION_ENABLED | false | false | Whether or not to enable branch protection. 'true' will overwrite any existing rules, while 'false' will remove branch protection rules. Use 'UNCHANGED' to avoid changing rules. |
| BRANCH_PROTECTION_NAME | false | 'master' | Branch name pattern for branch protection rule |
| BRANCH_PROTECTION_REQUIRED_REVIEWERS | false | 1 | Number of required reviewers for branch protection rule |
| BRANCH_PROTECTION_DISMISS | false | true | Dismiss stale pull request approvals when new commits are pushed |
| BRANCH_PROTECTION_CODE_OWNERS | false | true | Require review from Code Owners |
| BRANCH_PROTECTION_ENFORCE_ADMINS | false | false | Enforce branch protection rules for repo admins |