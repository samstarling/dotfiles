I live in the UK, and use British English. When asked to produce copy (e.g. a pull request description), use British English.

I use fish as a shell. When giving me commands to run, or scripts to execute, they must be compatible with fish.

<!-- BEGIN ARTEMIS MOBILE TESTING RULES -->
# Mobile Testing Mindset (ARTEMIS Integration)

Write executable tests based on device behavior verified with **ARTEMIS**. Before authoring a test, explore the target application and confirm its screens, transitions, and interactions. Use ARTEMIS device actions or ADB commands to investigate software and hardware behavior instead of assuming how an interaction works.

### 1. The Runnable Code Principle & ARTEMIS Exploration
- **When tasked with authoring tests**, deliver runnable test code with verified interactions and explicit wait conditions.
- Before writing any test code, you must use the ARTEMIS MCP tools to interactively run and explore the target application. This allows you to discover the exact sequence of UI states, transitions, and required interactions.
- Analyze the user's target testing framework to exploit its native capabilities and maximize test stability.
- **Timing & Latency Management (Exploration vs. Execution)**:
  - **Precise Timing in Final Code**: While ARTEMIS's AI exploration inherently involves model latency and is not strictly time-precise, you must bridge this gap in your final deliverables. Use ARTEMIS to discover and verify the interaction path, then implement exact, deterministic timing and wait conditions (`sleep`, explicit/implicit waits) in your authored test scripts, as local test execution runs without LLM overhead.
  - **Compensating for Model Latency During Exploration**: When delegating exploratory tasks to ARTEMIS that involve waiting periods (e.g., waiting 30 seconds for a page load or timer), adjust the requested wait duration in your task description based on the selected model's natural step interval:
    - **Flash Model**: The average processing interval between steps is roughly **5 seconds**. For a required 30-second delay, instruct the agent to wait for approximately **25 seconds**.
    - **Pro Model**: The processing interval between turns is typically **~30 seconds** (due to multi-agent planning and verification). The natural pipeline delay often covers the required waiting time without adding long explicit delay commands.
  - **Pragmatic Timing Judgment**: When a user request mentions performing an action for a specific duration (e.g., "stay on this screen for 2 minutes"), evaluate whether exact timing is functionally critical. Often, these durations are rough guidelines rather than strict test constraints—exercise flexibility and pragmatic engineering judgment to achieve the verification goal efficiently.


### 2. ARTEMIS Closed-Loop Architecture Mastery
Deeply understand and select between ARTEMIS's dual execution models (**ARTEMIS Flash** and **ARTEMIS Pro**) based on the task scenario, and master their corresponding workflows:

- **ARTEMIS Flash (Fast / Reactive Model)**:
  - **Applicable Scenarios**: Designed for simple, highly deterministic, lightweight UI operations or direct automation workflows. There is no step cap by default (history is compressed rather than truncated), so task length alone is not a reason to choose Pro; choose Pro when the task needs a persistent plan, verified checkpoints, notes or a written report, ADB / log diagnostics, or multi-branch exploration.
  - **Execution Mechanism (Reactive Loop)**: Does not enter the LangGraph multi-node orchestration: there is no Planner, no pre-execution safety net, and no Checker. `FlashRunner` receives the user's goal, the latest UI element list, and the live screenshot, performs "Observe-Think-Act" with a single LLM, and calls action tools until it reports the task status. It chains taps into one `click_sequence` to catch transient UI (auto-fading control bars, toasts) before they expire, and it can call `ask_explorer` for element grounding, `search_history` / `replay_steps` / `get_step_screenshot` to look up compressed earlier steps, and `video_analyzer` over the session recording. History lives in the same session transcript ledger as Pro (session-relative `T+mm:ss` clock, screenshots folded into visual summaries, older steps chunked into eras).

- **ARTEMIS Pro (Deep / Multi-Agent Graph-Driven Closed-Loop Model)**:
  - **Applicable Scenarios**: Designed for long-range, highly complex, dynamic multi-branch tasks; continuous monitoring / polling loops; and tasks requiring deep system diagnostics (ADB, logs, video), verified checkpoints, or a detailed written report.
  - **Execution Mechanism (Plan-Execute-Verify-Summarize Closed-Loop)**:
    - **Planner**: Deconstructs complex, high-level testing goals into a living Markdown task plan with milestones and `verify` / `assert` check items. Later milestone edits get an advisory review (a hint plus reason back to the Operator; the plan is never rolled back).
    - **Operator**: Consumes the plan, analyzes the current screen state (screenshots plus the UI element list, with the Explorer for grounding at the `explorer_mode` perception depth: `flash` 1-shot, `pro` 3-turn, `ultra` deep zoom), keeps notes, and executes precise device interactions; it can also recall compressed history, analyze the session recording, and run ADB commands as a supplement to UI actions.
    - **Safety Net & Execution Incidents**: A single turn-ending action is vetted by a pre-execution safety net (XML-first, pixel fallback). A multi-action turn is a **fast-action burst** that fires back to back without the safety net, which is how the Operator defeats turn latency on transient UI. When an action is intercepted or fails, the system opens an **execution incident** that persists in the Operator's context (with the consecutive-failure count shown as a fact) until a later action executes successfully; recovery is the Operator's own decision and there is no separate repair agent.
    - **Checker (Verification)**: A read-only verifier with the same observation tools as the Operator audits plan-declared checkpoints and performs an exit final review against the original goal; `verification_level` selects the depth (`off`, `final` = exit review only and the default, `checkpoints` = every checkpoint plus exit review, `strict` = checkpoints with a larger repair budget where a failed assert halts the run).
    - **Outputter (Optional)**: Synthesizes the entire execution trace into a human-readable report detailing every action step and visual result.

### 3. Device & Environment Constraints & Multi-Device Management
- **Device Selection & Multi-Device Execution**: ARTEMIS supports multi-device execution and per-device concurrency. You can control device targeting via two modes:
  - **Direct Device Specification**: Explicitly provide the target phone's serial number via `device_serial` to `mobile_run_task` or `mobile_get_device_state`. Tasks targeting distinct devices run concurrently without blocking each other.
  - **Automatic Device Selection**: When `device_serial` is omitted or set to `None`, ARTEMIS automatically selects an available connected device or allocates an idle device from the device pool.
- **Prioritize User Choice for Device Selection**:
  - When multiple connected devices or emulators are detected, or whenever device selection is ambiguous, **YOU MUST PRIORITIZE ASKING THE USER** to select or confirm their preferred device serial before launching a task.
- **Device Diagnosis with `adb devices`**:
  - Use `adb devices` (or `adb devices -l`) via bash command execution to diagnose attached hardware, inspect connection status (`device`, `unauthorized`, `offline`), and retrieve device serials and models whenever preparing tasks or troubleshooting device issues.
- **ADB & File Transfer**: While ARTEMIS excels at device automation, it operates within the device boundary. To extract diagnostic files, logs, or test artifacts from the mobile device to the host PC for further analysis, you must manually execute appropriate `adb` commands (e.g., `adb -s <serial> pull ...`).
- **Hardware Prerequisites**: Running ARTEMIS requires at least one physically connected, fully authorized Android device (e.g., a Pixel phone) or an active emulator.
- **Per-Device Mutual Exclusion**: ARTEMIS manages per-device execution mutexes (`DeviceExecutionLock`). A device can only execute a single task at a time (FIFO queue), while different devices can execute tasks in parallel.

### 4. Robust Test Code Design (The "Dynamic-First, Coordinate-Fallback" Philosophy)
*If your task involves authoring test code, you must adhere to the following design principles for maximum reliability:*
- **Adapt to Framework Capabilities**: You must first assess what locating mechanisms the user's test framework supports (e.g., resource IDs, XPath, text matching, OCR, image template matching, or absolute/relative coordinates).
- **The Core Principle: Dynamic-First, Coordinate-Fallback**:
  - Wherever supported by the framework, **always prioritize dynamic element locating** (using IDs, text, OCR, etc.) to ensure the test code can withstand UI layout drifts and resolution changes.
  - Use **absolute coordinates as a reliable fallback** to guarantee execution success when dynamic locators fail or are unavailable.
- **Implementing Resilient Locating Patterns**:
  - **Dual-Capable Frameworks**: If the framework supports both dynamic and coordinate-based locating, implement the **Try-Catch Fallback Pattern**:
    1. **Try**: Attempt to interact with the element using dynamic locators (IDs, OCR, text) for maximum resilience against UI changes.
    2. **Catch**: If the dynamic attempt fails, fall back to the precise absolute coordinates verified during your ARTEMIS exploration.
  - **Coordinate-Only Frameworks**: If the framework only supports coordinates, ensure the coordinates are well-documented, and where possible, parameterized or made relative to screen boundaries to mitigate resolution differences.
  - **Dynamic-Only Frameworks**: If the framework does not support coordinate-based clicks, focus entirely on generating highly robust dynamic locators, leveraging ARTEMIS's element descriptions and XML tree analysis.

### 5. Environment Self-Diagnosis (`mobile_diagnose`)
- **Diagnose before guessing**: Whenever an ARTEMIS tool returns an error, a task fails to start or is rejected, no device is found, or the user reports that ARTEMIS "doesn't work" in the IDE, call `mobile_diagnose` first. Do not troubleshoot by re-running `mobile_run_task` on trial and error, and do not ask the user to run `adb` commands by hand before you have the report.
- **If `mobile_diagnose` is not in your tool list at all**, the MCP server itself failed to start: check the IDE's MCP server log and run `uv run artemis doctor` in the project directory (the CLI shares the same checks).
- **Follow `next_steps` in order**: The report lists fixes in dependency order (Python runtime → config → MCP host → LLM credentials → device → optional video toolchain). `Run:` lines are single, local, non-destructive shell commands (one command per line, no `&&`) you may execute yourself (ask before installing software with winget / brew / apt). `Guidance:` lines describe something only the user can do (unlock the phone, tap "Allow" on the USB-debugging prompt, plug in a cable, free a port, tell you which IDE they use) — relay them verbatim. `Docs:` lines are references.
- **Let ARTEMIS self-heal first**: Call `mobile_diagnose(attempt_fix=true)` before asking for manual ADB intervention; it regenerates corrupted ADB RSA keys, restarts the ADB server when that is safe (no device ready, no task holding a device), and removes stale device locks / queue tickets left behind by crashed runners.
- **Deeper checks on demand**: `verify_credentials=true` validates the configured API keys live (~12s; use when a key exists but tasks fail with auth / quota errors; result in `credentials`). `probe_device=true` runs a true end-to-end check — screenshot plus UI hierarchy through UIAutomator (~20s; use when the device shows connected but observation or tasks fail; result in `device_probe`).
- **Emulators**: `launch_avd="<name>"` starts an installed Android Virtual Device in the background via ARTEMIS's emulator manager and returns immediately; boot takes 1-3 minutes, so re-run `mobile_diagnose` after ~60s. Never run `emulator -avd` in the shell yourself — it is a foreground process and hangs the shell.
- **Busy devices**: `tasks: {active, queued}` lists tasks currently holding or waiting for devices. A busy device means wait, or stop the task with `mobile_manage_task(action="stop", trace_id=...)`.
- **Credentials never go through the chat**: If the LLM key is missing, ask the user to add it to the `.env` file at the path the report shows (`host.env_file`) or to the MCP server's `env` block, then to restart the MCP server. `artemis init` is interactive and cannot be driven from a tool call.
- **Restart after configuration changes**: Settings are read when the server starts. After editing `.env`, `config/artemis.jsonc`, or the MCP client configuration, reload the MCP server in the IDE before calling `mobile_diagnose` again; otherwise it reports the old state.
- **Failed tasks**: `logs.last_failed_task` gives the trace id, its `stderr_log`, and `recent_errors` (the error lines from that stderr, so you need not open the file); read them before re-running the task. Repeat `mobile_diagnose` until `verdict` is `ready` or `degraded` before delegating tasks again (`degraded` means tasks can run but something optional is off: video tools, the OCR key, a secondary credential, or a host warning such as an interpreter mismatch or a squatted daemon port; relay its `[OPTIONAL]` steps to the user, do not loop on them).
<!-- END ARTEMIS MOBILE TESTING RULES -->

## Writing

- Keep it short. Lead with the answer, cut padding, and don't restate what I said.
- Use plain words. Define or replace jargon and code identifiers in prose meant for people, and use one term per concept.
- When I ask for the full list or full output, give all of it.

## Evidence

- Run the command that settles a question and quote its output. Otherwise call it a hypothesis and say what would confirm it.
- Check current code and live state, not memory or old docs. "No errors, 64 warnings" is not clean. Look at a screenshot before claiming a visual fix.

## Deciding

- Present options, findings and next steps as a numbered list with a recommendation, so I can answer "do 1 and 3".
- When something is mine to decide (intent, taste, customers, ownership), ask. Answer what you can from code or data first. Use the agent's question tool if it has one (AskUserQuestion in Claude Code; request_user_input in Codex, which only offers it in Plan mode), in as few rounds as its limits allow. Otherwise ask in a numbered list with a recommendation.
- Approval means an explicit yes to that specific action. Picking a fix doesn't approve pushing it.
- Take my decisions literally. Once I accept a risk, stop raising it.
- End a report with one recommended next action.

## Scope

- Stay inside the task. Side issues (stray bugs, pre-existing lint noise, unrelated improvements) become drafted tickets with a title and a line of why. File them only once I've said where they belong, and don't fix them inline.
- Never bundle unrelated changes into a commit or PR.
- When a decision changes a ticket or doc, offer to update it there and then. Re-read it first, because I edit by hand, and make a targeted edit that keeps my wording.

## Git and external systems

- Commit atomically while you work. **Never push until I ask.** Opening a PR I asked for counts as asking; after that, each push needs my approval.
- Don't commit to the main branch without my approval.
- Writes to trackers, docs, chat or feature flags need my approval.
- **Never post comments or reviews, approve, or resolve threads on the code host (GitHub, GitLab and so on).** Give me a draft and I'll post it myself.
- Production reads need my approval once per session; production writes need it every time. Nothing customers see happens without my approval.

## Pull requests

- Review with the repo's review skill if it has one, otherwise the agent's built-in reviewer (the `code-review` skill in Claude Code, the `review-agent` skill in Codex), against an explicit target: a branch, a PR number or one PR in a stack. Don't use its comment or fix modes. If I move to open a PR and nothing has reviewed the current diff, ask whether to review first. Give findings as one numbered list, out-of-scope ones separate, and fix only what I pick.
- PR body: the problem and what the PR does in plain prose, how we checked it's safe (with measured numbers), and anything to do before merging last. Write the body to a file, and include before and after screenshots for UI changes. Re-read the live body before every edit, because I hand-edit it. After pushing fixes, say if it's now wrong and propose a targeted edit.
- Reviewer comments, from bots or people: check each against the current code and give a numbered verdict (valid, false positive, judgement call) with evidence. Fix what I pick, and draft one reply per thread for me to post once the fix is pushed.
- CI: say whether the PR caused the failure or it's flaky or unrelated. Fix the PR's own failures; unrelated ones become drafted tickets.
- Conflicts: keep what both sides intended unless I say otherwise. If migrations clash, renumber the feature branch's, never main's.
- Someone else's PR: a short verdict and numbered `file:line` spots, each with a draft comment. Don't touch their branch.

## Engineering habits

- Before ticket work, check `git status` and `git worktree list`. Reuse a worktree for the ticket if there is one; otherwise create one with the repo's tooling.
- Read the code you'll change and check every assumption you'll build on. Look for an existing helper, library or vendor pattern before writing mechanism.
- Commit each logical step once lint and typecheck pass. Reuse existing names, helpers and the tested write path. Comments say why, never what, and stay sparser than the surrounding file.
- Before reporting, run lint, typecheck, the related tests and CI's format checks for every touched package, and re-read every comment you added.
- For UI, use my running dev server, check every state in a browser with realistic data, and screenshot it. When I iterate from screenshots, apply exactly what I ask and nothing else.
- Don't rename migrations already on main.
- Evals: use the repo's eval tooling if it has some, and never put eval questions, answers or fixtures in the prompt being scored. To fix one failure, capture the case, confirm it fails (3–5 runs if flaky), make a generic fix, confirm it passes and check related cases; then test with a hidden case written in a separate session, and never read or tune against it. Hill-climb against a held-out split, read raw outputs as well as scores, and don't trust one run.
- Agree a finish line for long runs (evals, model checking, device runs) up front, and cut to a subset rather than running overnight.

## Habits

- Follow the repo's commit format. Otherwise use imperative, sentence case, under about 70 characters.
- Never read secret files such as `.env`. If a command hangs, it may be waiting on a password or signing prompt: ask me rather than retrying or killing it.
- Use subagents for parallel work when it helps or when I ask, including writing code. Use the model and effort I name.
- Write briefs for other sessions or agents to a file and give me the path. Long pasted messages arrive truncated.
- Never amend or rebase pushed commits, and ask before any force-push. Never merge; that's my call.
