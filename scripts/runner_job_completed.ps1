# The job-completed hook of the self-hosted runners (ACTIONS_RUNNER_HOOK_JOB_COMPLETED in each runner's .env, written
# by scripts/runner_env.ps1). A hook takes no arguments, so this only hands over to the window guard: it lists the
# windows the job opened as warnings in the job's log. Never fails the job.
& (Join-Path $PSScriptRoot 'runner_window_guard.ps1') -Report
exit 0
