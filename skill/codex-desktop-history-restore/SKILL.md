---
name: codex-desktop-history-restore
description: Recover Codex Desktop work after history or provider issues using one of two explicit modes: `handoff` for fast context continuation in a new session, or `restore` for repairing local sidebar history, project roots, and original-thread rendering. Use when old chats disappear from the sidebar, only the first user message shows, account or provider switching breaks resume, or the user mainly wants to keep working without waiting for the UI to be repaired.
---

# Codex Desktop History Restore

Use this skill when Codex Desktop local history exists on disk but the UI fails to show or resume it.

## Mode Selection

This skill has only two modes:

- `handoff`: the user wants to continue the work quickly in a new account, new window, or new conversation, and does not require the original left-sidebar thread to come back immediately
- `restore`: the user wants Codex local history itself to recover, including sidebar entries, project roots, and opening the original thread again

Pick the mode before changing anything:

- If the user says "I just want to continue the work right now", prefer `handoff`.
- If the user says "I want the original thread back in the left sidebar", prefer `restore`.
- Do not silently switch from `handoff` to `restore` or vice versa.

If the user is vague, ask or state the choice in this compact form:

- `handoff`: fastest path, keeps work moving, does not promise the old sidebar thread comes back
- `restore`: slower path, mutates local state, aims to make the original thread and sidebar history usable again

Recommended default when the user is blocked and time-sensitive:

- choose `handoff` first

Recommended default when the user explicitly cares about Codex Desktop history fidelity:

- choose `restore`

## What this skill fixes

- Sidebar Project roots still show but chats inside are missing.
- Non-project chats partially show but opening them only renders the first user message.
- The app shows `failed to restore conversation` or `failed to load configuration`.
- Old threads reference stale provider ids like `openaihttp` after the user switched to API-key mode.
- Project/workspace roots disappeared from the left sidebar after local state drift.
- The user signs into a different subscription account on the same Mac and the existing local history is still on disk but no longer restores correctly in the UI.

## Safety rules

- In `handoff` mode, prefer read-only export and do not modify local Codex state.
- In `restore` mode, back up local state before changing anything.
- Never delete history, truncate databases, or clear caches until a reversible repair path fails.
- Prefer metadata/index repair over content mutation.
- If the app is running, expect stale in-memory state; plan for a full process restart after repair.
- Always inspect `~/.codex/auth.json` before choosing a target provider.
- Never migrate active threads to `custom` unless the current auth mode and config actually support it.
- Prefer minimal, targeted backups first; do not clone huge state trees unless the repair really needs them.
- Do not run `restore` while actively using a temporary continuation conversation for new work. Finish the current turn first, then restore in a separate recovery turn if possible.
- If `restore` is chosen, explicitly tell the user that the skill may require a full Codex restart and may temporarily reshuffle active sidebar threads.

## Applicability check

This skill is intended for local-history recovery on the same machine and same macOS user.

It is a good fit when:

- the user changed provider mode
- the user signed into a different subscription account
- the local Codex data directories still exist
- the chats appear to exist locally but the UI no longer restores them correctly
- the user wants either a quick session handoff or a true local-history repair

It is not sufficient by itself when:

- the user moved to a different Mac
- the user switched to a different macOS account
- `~/.codex` or `~/Library/Application Support/Codex` was deleted
- the desired history only existed remotely and was never stored on this machine

## Handoff mode

Use this when the user wants to continue the task, not necessarily recover the original UI thread.

Goals:

- identify the most relevant prior thread
- summarize enough context to continue safely
- hand the next session a clear continuation prompt or handoff file path

Rules:

- do not edit `state_5.sqlite`, rollout JSONL, `session_index.jsonl`, or `.codex-global-state.json`
- do not change `config.toml` provider settings
- do not create backups by default, because the mode is read-only
- if a dedicated handoff tool is available, prefer that path
- if not, produce a concise local handoff from read-only inspection of the target thread, including session id, cwd, title, recent state, and continuation instructions

Suggested workflow:

1. Inspect recent sessions and shortlist plausible candidates.
2. Choose the best match by cwd, title, recency, and what the user says they were working on.
3. Extract only the information needed to continue work.
4. Hand the next session a file path or concise continuation prompt instead of pasting long raw transcript content.

The ideal handoff package contains:

- selected thread id
- cwd or project root
- thread title or first-user-message summary
- current known objective
- recent decisions or blockers
- key files touched or likely to be touched next
- exact instruction for the next session to continue without re-discovery

Expected deliverable in `handoff` mode:

- which prior thread was selected
- why it was selected
- what project/cwd it belongs to
- what the next session should read or do first

## Restore mode

Use this when the user wants the original Codex local history and sidebar behavior repaired.

Only `restore` mode may mutate local state.

Suggested workflow:

1. Detect auth mode and the correct target provider.
2. Fix config/provider compatibility before migrating thread metadata.
3. Repair indexed thread metadata and rollout metadata to the same target provider.
4. Rebuild sidebar index and restore workspace roots.
5. Restart Codex fully.
6. Verify thread count, provider distribution, rollout consistency, and UI recovery.

## Backup first, but keep it minimal by default

This section applies to `restore` mode.

Read `~/.codex/auth.json` first to determine whether the machine is currently using:

- `auth_mode = chatgpt`
- `auth_mode = apikey`

For most repairs, back up only:

- `~/.codex/config.toml`
- `~/.codex/auth.json`
- `~/.codex/state_5.sqlite*`
- `~/.codex/session_index.jsonl*`
- `~/.codex/.codex-global-state.json*`
- only the rollout JSONL files for threads that will actually be modified

Treat this as the default backup profile.

Escalate to full directory backups only when:

- you are about to modify Electron/frontend storage directly
- you cannot isolate the affected rollout files
- a minimal repair already failed and you need a wider rollback point

Expanded backups, when justified:

- `~/.codex/sessions/`
- `~/.codex/archived_sessions/`
- `~/Library/Application Support/Codex/`
- `~/Library/Caches/com.openai.codex/`
- `~/Library/Preferences/com.openai.codex.plist`

Do not make a full copy of all `~/.codex/sessions/` just because it feels safer. Full session backups are expensive and should be an exception, not the baseline.

Prefer `rsync -a` into a timestamped backup directory.

## Key local state locations

Backend/local thread state:

- `~/.codex/state_5.sqlite`
- `~/.codex/session_index.jsonl`
- `~/.codex/.codex-global-state.json`
- `~/.codex/auth.json`
- `~/.codex/sessions/<yyyy>/<mm>/<dd>/rollout-*.jsonl`

Electron/frontend state:

- `~/Library/Application Support/Codex/Local Storage/leveldb`
- `~/Library/Application Support/Codex/Session Storage`
- `~/Library/Application Support/Codex/Preferences`
- `~/Library/Logs/com.openai.codex/<yyyy>/<mm>/<dd>/*.log`

## Normal repair order

This section applies to `restore` mode.

### 1. Determine auth mode and target provider first

Inspect `~/.codex/auth.json`.

Rules:

- If `auth_mode == "chatgpt"`, active threads should normally use the built-in `openai` provider.
- If `auth_mode == "chatgpt"`, do not set top-level `model_provider = "custom"` and do not rely on a custom `base_url`.
- If `auth_mode == "apikey"`, a custom provider can be valid, but only if it is actually registered in `config.toml`.
- When the user says they switch between subscription and API key modes, treat provider migration as auth-dependent, not one-size-fits-all.

Target-provider matrix:

- `chatgpt` -> prefer `openai`
- `apikey` with valid custom provider configured -> prefer that custom provider
- `apikey` without a valid custom provider configured -> fix config before touching thread metadata

### 2. Fix config loading first

Inspect `~/.codex/config.toml`.

Common failure:

- User-defined provider ids reuse built-in ids like `openai`.

Rules:

- Never override built-in provider ids.
- Rename custom providers to something like `custom`, `openai_custom`, or `openai-custom`.
- Update any references in top-level provider/model settings if needed.

If logs show:

- `model_providers contains reserved built-in provider IDs: openai`

then fix config before touching history indexes.

Also treat these as config/provider mismatch signals:

- `failed to load configuration: Model provider \`custom\` not found`
- `failed to load configuration: Model provider \`openaihttp\` not found`
- `unknown conversation` immediately after a provider migration

### 3. Check thread inventory

Query `threads` in `~/.codex/state_5.sqlite`.

Useful checks:

- unarchived thread count
- model_provider distribution
- cwd distribution
- rollout_path presence

If old unarchived threads use stale providers like `openaihttp`, `openai`, or `custom`, and the current auth/config combination does not support those ids, Codex Desktop may fail to resume them and will often only show `first_user_message`.

### 4. Rebuild sidebar/thread title index

If `session_index.jsonl` count is lower than unarchived `threads` count, rebuild it from `threads where archived=0`.

Each line should contain:

- `id`
- `thread_name`
- `updated_at`

This restores missing left-sidebar chat entries, but by itself may not fix full conversation rendering.

### 5. Restore workspace/project roots in global UI state

Inspect `~/.codex/.codex-global-state.json`.

Important keys:

- `electron-saved-workspace-roots`
- `project-order`
- `active-workspace-roots`
- `electron-workspace-root-labels`
- `projectless-thread-ids`
- `thread-workspace-root-hints`

If historical roots are missing here, sidebar Projects may collapse to only a few current roots even though threads still exist.

Re-add missing workspace roots carefully without deleting existing ones.

### 6. Migrate stale provider metadata in thread index

If old unarchived threads use stale provider ids that no longer exist in config:

- update `threads.model_provider` in `state_5.sqlite`

Prefer migrating to the provider derived from `auth.json` plus the currently valid config.

Examples:

- `chatgpt` mode -> migrate active threads to `openai`
- `apikey` mode with a live custom provider -> migrate active threads to that custom provider

Do not migrate active threads to `custom` just because a custom section exists historically.

This is metadata repair, not content repair.

### 7. Migrate stale provider metadata in rollout JSONL

This step is critical when the UI still only shows the first user message.

For each unarchived `rollout_path`, inspect the first JSONL line:

- `type == "session_meta"`
- `payload.model_provider`

If `payload.model_provider` is stale, e.g. `openaihttp`, `openai`, or `custom`, update it to the same target provider chosen for SQLite.

Codex Desktop may use this session-level metadata during `thread/resume`, so fixing only the SQLite index is often insufficient.

### 8. Full process restart

Do not rely on a soft window refresh.

If Codex keeps stale in-memory state:

- fully quit the app
- if needed, kill Codex Desktop helper/app-server processes
- reopen Codex

Look for multiple lingering processes such as:

- `Codex Helper`
- `codex app-server --listen stdio://`
- old npm/global codex app-server processes

If necessary, use process-level restart rather than window-level quit.

## How to verify

Read the newest file in:

- `~/Library/Logs/com.openai.codex/<yyyy>/<mm>/<dd>/`

Search for:

- `thread/list`
- `thread/resume`
- `Failed to resume conversation`
- `failed to load configuration`
- `failed to restore conversation`
- `unknown conversation`

Success criteria:

- no stale provider errors
- active-thread provider distribution matches the current auth mode
- rollout `session_meta.payload.model_provider` matches the same target provider
- historical chats appear under Projects and/or regular chat history
- opening a thread shows assistant replies, not only the first user message
- repeated `thread/resume` failures stop

For `handoff` mode, success is simpler:

- the selected thread is clearly identified
- the handoff artifact or summary is readable
- the continuation instructions are explicit enough for a new session to proceed without guessing
- no local Codex state was modified during handoff

## Backup cleanup after success

This section applies only to `restore` mode.

After the user confirms the restore is successful and Codex has been fully restarted:

- inspect the backups created during this repair session
- keep one latest known-good successful backup
- keep any backup that contains unique rollout files or a pre-fix config state not preserved elsewhere
- delete intermediate failed-attempt backups that are fully superseded by the retained backup
- if a full-directory backup was created but the final repair only changed SQLite, index, global state, and a finite set of rollout files, prefer deleting that oversized backup after success

Do not keep large full copies of `sessions/` or `Application Support/Codex` indefinitely when a smaller retained backup already covers the actual repair footprint.

If the user confirms they do not want long-term rollback points, it is acceptable to delete all superseded repair-session backups and keep only the latest minimal successful backup.

## Typical root-cause pattern

When a user switches from subscription/OpenAI-hosted mode to API-key/custom provider mode:

1. Old threads still exist on disk.
2. Old thread metadata still points at `openaihttp` or another removed provider id.
3. Desktop can list some threads but cannot fully resume them.
4. UI falls back to `first_user_message`, causing “only first user message” symptoms.
5. Repeated failed resume attempts can trigger flicker, refresh loops, or restore-failed toasts.

The same local-history failure pattern can also happen when the user signs into a different subscription account on the same Mac:

1. Local thread/session files remain on disk.
2. Account/session-level UI state changes, but old local history is still present.
3. The app lists partial history or only project roots.
4. Resume/hydration fails and the UI falls back to a degraded conversation preview.

Another common failure pattern is auth-mode mismatch:

1. The machine is currently using `auth_mode = chatgpt`.
2. A repair script migrates active threads to `custom` and/or writes `model_provider = "custom"` into `config.toml`.
3. Codex starts rendering the UI as Custom mode, but the actual subscription auth path is incompatible with that provider config.
4. Reconnect or later cleanup removes the custom provider config.
5. Active threads still point at `custom`, so sidebar restore fails again until SQLite, rollout metadata, and index are migrated back to `openai`.

## Minimal commands to adapt

Use local inspection first:

- `python3 -c 'import json, os; print(json.load(open(os.path.expanduser(\"~/.codex/auth.json\")))[\"auth_mode\"])'`
- `sqlite3 ~/.codex/state_5.sqlite '.tables'`
- `sqlite3 ~/.codex/state_5.sqlite "select model_provider, count(*) from threads where archived=0 group by model_provider;"`
- `wc -l ~/.codex/session_index.jsonl`
- `sed -n '1,5p' ~/.codex/sessions/.../rollout-...jsonl`
- `rg -n "thread/resume|failed to load configuration|Failed to resume conversation" ~/Library/Logs/com.openai.codex/<date>/*.log`

Use file edits only after backup.

## Deliverable expectations

After `restore`, report:

- what auth mode was detected
- which target provider was chosen and why
- what was backed up
- whether any oversized backup was skipped because a targeted backup was sufficient
- which config issues were fixed
- how many threads were found
- whether stale provider ids were migrated in SQLite
- whether stale provider ids were migrated in rollout JSONL
- whether sidebar workspace roots were restored
- whether logs stopped reporting restore failures
- which backups were retained and which were deleted after success
- any remaining unrecoverable threads

After `handoff`, report:

- which thread was selected
- what evidence was used to match it
- what continuation artifact or summary was produced
- the exact next-step instruction for the new session

## Interaction style

When driving this skill:

- be explicit about which mode is being used
- keep user-facing explanations short and operational
- do not over-explain internal file formats unless the user asks
- if `restore` is risky or likely to interrupt current work, say so before changing anything
- if `handoff` is enough, prefer it over invasive repair
