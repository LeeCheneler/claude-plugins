# leecheneler-plugins

Personal [Claude Code plugins](https://docs.anthropic.com/en/docs/claude-code/plugins) marketplace. Opinionated developer workflows for conventional commits, pull requests, merges, GitHub issue linking, and dependency patching.

## Installation

```sh
/plugin marketplace add LeeCheneler/leecheneler-plugins
/plugin install dev@leecheneler-plugins
```

## Updating

```sh
/plugin marketplace update leecheneler-plugins
```

## Plugins

### dev

Developer workflows for conventional commits, pull requests, merges, GitHub issues, and dependency patching.

| Skill              | Command               | Description                                                                       |
| ------------------ | --------------------- | --------------------------------------------------------------------------------- |
| commit             | `/commit`             | Conventional commits with branch safety guards and GitHub issue linking           |
| pr                 | `/pr`                 | Pull request creation with GitHub issue linking and PR template support           |
| merge              | `/merge`              | Squash-merge a PR after CI passes, with branch cleanup                            |
| issue              | `/issue`              | Structured GitHub issue creation for user stories, bugs, and chores               |
| patch-dependencies | `/patch-dependencies` | Patch Dependabot alerts across repos via overrides/resolutions, lockfile-only PRs |
