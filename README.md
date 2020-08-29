<h1 align="center">github-action-file-sync</h1>


<div align="center">

<b>Github Action to sync files across repos</b>

[![version](https://img.shields.io/github/v/release/kbrashears5/github-action-repo-setup)](https://img.shields.io/github/v/release/kbrashears5/github-action-repo-setup)

</div>


# Use Cases
Great for keeping repository settings in sync across all repos. I constantly forget when creating new repos to go tweak all my repository settings how I like them, set up branch policys, etc. This allows me to add my new repo to the list (or just take the default of all and have no steps) and automatically have my settings there.

# Setup
Create a new file called `/.github/workflows/repo-setup.yml` that looks like so:
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
      - name: Fetching Local Repository
        uses: actions/checkout@master
      - name: Repo Setup
        uses: kbrashears5/github-action-repo-setup@v1.0.0
        with:
          REPOSITORIES: |
            kbrashears5/github-action-repo-setup
          TOKEN: ${{ secrets.ACTIONS }}
          ALLOW_ISSUES: 'true'
          ALLOW_PROJECTS: 'true'
          ALLOW_WIKI: 'true'
          SQUASH_MERGE: 'true'
          MERGE_COMMIT: 'true'
          REBASE_MERGE: 'true'
          DELETE_HEAD: 'false'
```
## Parameters
| Parameter | Required | Default | Description |
| --- | --- | --- | --- |
| REPOSITORIES | false | 'ALL' | Github repositories to setup. Default will get all public repositories for your username |
| ALLOW_ISSUES | false | true | Whether or not to allow issues on the repo |
| ALLOW_PROJECTS | false | true | Whether or not to allow projects on the repo |
| ALLOW_WIKI | false | true | Whether or not to allow wiki on the repo |
| SQUASH_MERGE | true | true | Whether or not to allow squash merges on the repo |
| MERGE_COMMIT | true | true | Whether or not to allow merge commits on the repo |
| REBASE_MERGE | true | true | Whether or not to allow rebase merges on the repo |
| DELETE_HEAD | true | false | Whether or not to delete head branch after merges |
| TOKEN | true |  |Personal Access Token with Repo scope |