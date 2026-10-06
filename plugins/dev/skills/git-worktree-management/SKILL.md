---
name: git-worktree-management
description: Manage git worktrees with the `new-worktree` and `rm-worktree` commands — creating a ready-to-use isolated worktree (bootstrap included) and tearing one down. Load when creating or cleaning up a worktree, e.g. kicking off work or tidying after a PR.
---

# Git Worktree Management

Two shell helpers (in `~/.dotfiles/bin`) wrap `git worktree` so worktrees are created usable and removed cleanly. These are the authoritative usage notes, taken from the scripts themselves. The **full** usage of both commands is reproduced below — you should not need to run either with `-h` to use it.

Requires `new-worktree` and `rm-worktree` on PATH; if unavailable, stop and report the prerequisite rather than substituting an unverified workflow.

## `new-worktree` — create a ready-to-use worktree

```
new-worktree <repo-dir> <branch> [base-ref]
```

Arguments:

| Arg | Meaning |
|---|---|
| `<repo-dir>` | Path to the repo — the main checkout **or any of its existing worktrees** (e.g. `./example-repo` or `/path/to/example-repo`). |
| `<branch>` | The branch to work on. Checked out as-is if it exists locally or on `origin`; otherwise created from `base-ref`. **Use a feature branch here**, e.g. `feat/JN-3554-cleanup` or `fix/foo`. |
| `[base-ref]` | Optional. Base for a *brand-new* branch. **Defaults to `origin/main`.** This is **not** the worktree name. |

**You do not pick the worktree directory name.** It's derived automatically and created as a **sibling** of the source checkout:

```
<repo>-<ticket-id>            # branch has a ticket id, e.g. feat/JN-3554-… → example-repo-JN-3554
<repo>-<slugified-branch>     # otherwise, e.g. feat/foo-bar → example-repo-feat-foo-bar
```

### Examples

```sh
new-worktree ./example-repo feat/JN-3554-cleanup-env        # → sibling dir example-repo-JN-3554, based on origin/main
new-worktree ./example-repo fix/refactor main               # same, but explicitly basing the new branch on/main
new-worktree /path/to/example-repo feat/my-thing
```

`feat/JN-3554-cleanup-env` has ticket `JN-3554`, so the worktree lands in `example-repo-JN-3554`.

### What it bootstraps (worktree is usable immediately)

- **Refreshes refs** (`git fetch origin`) so `origin/main` and the branch are current.
- **`mise trust`** the worktree (if mise is installed) so it won't prompt on first `cd`.
- **Symlinks git-ignored `.env` files** from the source checkout into the worktree at the same paths. They're *shared* — edits affect every worktree. If a tool needs per-worktree values, replace a symlink with a copy (the script prints how).
- **Installs JS deps** for every lockfile found, using the matching manager: `pnpm-lock.yaml → pnpm`, `yarn.lock → yarn`, `package-lock.json → npm`, `bun.lock / bun.lockb → bun`. Falls back to `mise exec` when the manager isn't on PATH.

## `rm-worktree` — tear one down

```
rm-worktree <worktree-dir> [-f|--force]
```

Arguments:

| Arg | Meaning |
|---|---|
| `<worktree-dir>` | The worktree to remove, **or any path inside it**. |
| `-f, --force` | Remove even with uncommitted changes. |

### Behaviour

- **Refuses** to remove the source checkout itself, and **refuses** a dirty worktree without `--force`. (Ignored files — `node_modules`, `.env` symlinks — never count as dirt.)
- **Removes the worktree and its directory**, then prunes.
- **Deletes the branch** it was on (with `-D`, since squash merges hide merged-ness; git prints the sha, so it's recoverable). The default branch is **never** deleted.
- **Fast-forward pulls the source checkout** (with `--no-rebase --ff-only`) *only* if it's currently sitting on the default branch — so main stays current without ever force-merging.

### The normal teardown — a matched example

Create → work → PR merged → tear down:

```sh
new-worktree ./example-repo feat/JN-3554-cleanup-env   # → sibling dir example-repo-JN-3554
# …do the work, PR gets merged…
rm-worktree ./example-repo-JN-3554                     # pass the dir (or any path inside it)
```

No `-f` is needed in the normal case: a merged/clean worktree has no uncommitted changes, so the default refusal doesn't trigger. Most teardowns are exactly this — a bare `rm-worktree <dir>`.

### Finding the directory at teardown

You don't need `-h` to find the directory. If you're not sure which path to pass (e.g. cleaning up in a fresh session), name the worktrees instead:

```sh
git worktree list    # from any checkout of the repo — one line per worktree: <path> <commit sha> <branch>
```

That prints the exact path. Or derive it: the worktree is a **sibling** of the source checkout named `<repo>-<ticket-id>` (or `<repo>-<slug>`).

## How to call this from `dev:dev-work-kickoff`

- **Create:** `new-worktree <repo-dir> <feature-branch>` — let it derive the name and default base. Give the base-ref explicitly only when you're not branching from `origin/main`.
- **Teardown after the PR is merged/finished:** `rm-worktree <worktree-dir>`. If you don't know the dir, `git worktree list` first (you don't need `rm-worktree -h`).
- If unsure of the current flags, `new-worktree -h` / `rm-worktree -h` prints the usage.
