# leecheneler-plugins

Personal [Claude Code plugins](https://code.claude.com/docs/en/plugins) marketplace. Opinionated skills for development kickoff, software design, testing, frontend design, change reviews, user stories, worktree management, and game development.

## Installation

```sh
/plugin marketplace add LeeCheneler/claude-plugins
/plugin install dev@leecheneler-plugins
```

## Updating

```sh
/plugin marketplace update leecheneler-plugins
```

## Plugins

### dev

Development guidance with a worktree-based lifecycle, commit-by-commit sign-off, and user-led browser testing. Skills load automatically when relevant or can be invoked with their namespaced commands. Change reviews require an explicit request.

| Skill | Command | Description |
| --- | --- | --- |
| dev-work-kickoff | `/dev:dev-work-kickoff` | Development lifecycle from local repo discovery through worktrees, commit sign-off, and PR creation |
| frontend-design | `/dev:frontend-design` | Web interface design, implementation, accessibility, and visual polish |
| game-engine-handbook | `/dev:game-engine-handbook` | Self-contained public API reference for `@leecheneler/game-engine` |
| git-worktree-management | `/dev:git-worktree-management` | Create and clean up worktrees with the `new-worktree` and `rm-worktree` helpers |
| review-change | `/dev:review-change` | Read-only, evidence-based review of a diff, branch, or PR on request |
| software-design | `/dev:software-design` | Maintainable software design, implementation, and architecture review |
| testing-methodology | `/dev:testing-methodology` | Risk-based testing and test-quality review |
| user-stories | `/dev:user-stories` | Agent-ready stories with testable acceptance criteria and constraints |

#### Prerequisites

The worktree lifecycle requires Lee's `new-worktree` and `rm-worktree` shell helpers on PATH, normally from `~/.dotfiles/bin`. These helpers are not bundled with this plugin. If either is unavailable, the skills stop and report the missing prerequisite rather than substitute a different workflow.

The kickoff skill looks for existing repositories under `~/projects`; it does not clone missing repositories by default. Commits require explicit sign-off, and browser testing is user-led unless requested otherwise.
