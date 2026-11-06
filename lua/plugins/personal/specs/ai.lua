---@module 'plugins.personal.specs.ai'
--- Personal plugin specs: AI.
---
--- Provider-agnostic ask/stream layer and buffer-context helpers.
---
--- Category names follow the plugin website's registry
--- (wkd/src/data/registry.json). Source control -- local vs. remote vs.
--- disabled -- is NOT decided here but in plugins.personal.core.source; this
--- file only declares the specs. Registered from plugins/personal/init.lua.

---@type LazyPluginSpec[]
return {
  -- Provider-agnostic ask/stream layer (claude/ollama/openai/gemini/ai_desktop),
  -- built on lib.nvim.net.curl. `keys`/`cmd` load it lazily. `ai_prefix` is
  -- shared with opts, and TESTS/plugins_keys_mirror_spec.lua fails when the keys
  -- table and the plugin's own mappings drift apart.
  (function()
    -- ai.nvim's default keymap prefix "<leader>a" collides with the Avante
    -- mappings ("<leader>aa/ae/ar/af/as") of config/ai/anthropic, so the prefix
    -- is moved one level down to "<leader>ai" to let both coexist.
    local ai_prefix = "<leader>ai"

    ---@type table[]
    local ai_keys = {}
    for _, m in ipairs({
      { "a", "Ask (prompt for text)" },
      { "s", "Quick action: stream context + a typed task" },
      { "e", "Explain (badge, no panel)" },
      { "c", "Ask about the last message (editable first)" },
      { "r", "Rewrite current line with AI-generated code" },
      { "o", "Insert AI-generated code after current line" },
      { "O", "Insert AI-generated code before current line" },
      { "n", "Switch to the next agent" },
      { "x", "Stop every running stream" },
    }) do
      ai_keys[#ai_keys + 1] = { ai_prefix .. m[1], desc = "[AI] " .. m[2] }
    end
    -- What acts on a text also binds in visual mode (selection instead of buffer/cwd).
    for _, m in ipairs({
      { "a", "Ask about the selection" },
      { "s", "Quick action: stream selection + a typed task" },
      { "e", "Explain selection (badge, no panel)" },
      { "c", "Ask about the selection (editable first)" },
      { "r", "Rewrite selection with AI-generated code" },
      { "o", "Insert AI-generated code after selection" },
      { "O", "Insert AI-generated code before selection" },
    }) do
      ai_keys[#ai_keys + 1] = { ai_prefix .. m[1], mode = "v", desc = "[AI] " .. m[2] }
    end

    return {
      "WKDSteve/ai.nvim",
      cmd = "Ai",
      keys = ai_keys,
      -- Inline completion's keymaps (trigger/accept/dismiss, insert mode) are
      -- installed by ai.nvim's setup(), and neither `cmd` nor `keys` fires from
      -- plain typing. `InsertEnter` loads the plugin the first time any buffer
      -- enters insert mode, so those keymaps exist from then on without
      -- resorting to `lazy = false`.
      event = "InsertEnter",
      -- ui.nvim: the panel, the badge and the actions render exclusively
      -- through ui.kit, with no fallback. Completion itself does not need it
      -- (the ghost text uses raw extmarks), so this dependency only matters
      -- for the other features.
      dependencies = { "WKDSteve/lib.nvim", "WKDSteve/ui.nvim" },
      opts = {
        -- Active provider id, or "auto" to pick the first available one in
        -- `provider_order`.
        -- provider = "auto",
        -- Order that "auto" walks. "ai_desktop" is last because it needs a local
        -- server you run yourself. Replaces the list, so give it in full.
        -- provider_order = { "claude", "ollama", "openai", "gemini", "ai_desktop" },
        -- Default model per provider id, e.g. { claude = "claude-opus-4-5" };
        -- empty = each provider's own built-in default.
        model = { claude = "claude-sonnet-5-5", ai_desktop = "claude-haiku-5-5" },
        -- Request timeout in ms.
        -- timeout_ms = 60000,

        -- ui = {
        --   -- Render the streaming answer panel and the explain badge.
        --   enable = true,
        --   -- Progress indicator: "auto" | "notify" | "statusline" | "fidget" | "float".
        --   progress_style = "auto",
        --   -- ui.kit theme/preset of the answer panel.
        --   panel_theme = "rounded",
        --   -- Auto-dismiss delay of the explain badge, in ms.
        --   badge_timeout_ms = 6000,
        -- },

        keymaps = {
          -- Install the action keymaps (<prefix>a / s / e).
          -- enable = true,
          -- Moved one level down so the actions do not collide with the Avante
          -- mappings (see `ai_prefix` above).
          -- Default: "<leader>a".
          prefix = ai_prefix,
        },

        -- which_key = {
        --   -- Label the configured keymaps in which-key when it is installed.
        --   enable = true,
        -- },

        -- usercmds = {
        --   -- Register the :Ai command.
        --   enable = true,
        -- },

        -- Default context assembly for the quick-action keymaps (:Ai ask/stream
        -- build no context of their own).
        -- context = {
        --   -- The whole current buffer.
        --   buffer = false,
        --   -- The current visual selection, if any.
        --   selection = true,
        --   -- vim.diagnostic.get() of the current buffer.
        --   diagnostics = false,
        --   -- A harvest sweep of the cwd (expensive).
        --   cwd = false,
        --   -- The flattened JSON/YAML/XML block under the cursor (needs data.nvim).
        --   structured_data = false,
        --   -- Both sides of every unresolved merge conflict (needs gitsuite.nvim).
        --   conflict = false,
        -- },

        -- Ghost-text completion at the cursor (see docs/configuration.md in the
        -- ai.nvim repo).
        completion = {
          -- Turn inline completion on.
          -- Default: true (equals the default, set explicitly to keep it on).
          enable = true,
          -- "manual": only the trigger keymap (<C-\><C-a> by default) fires a
          -- suggestion. Kept off "auto" on purpose: auto fires an API call
          -- (possibly a paid one) on every idle pause while typing.
          -- Default: "manual" (equals the default, set explicitly so the
          -- choice stays visible).
          trigger = "manual",
          -- Idle debounce before an "auto" suggestion fires, in ms; unused in
          -- "manual" mode.
          -- idle_ms = 500,
          -- Lines of buffer context sent before/after the cursor.
          -- max_context_lines = 60,
          -- Response-length cap of a completion request (a whole number >= 1; only
          -- the claude provider reads it). An answer cut off at the cap is discarded.
          -- max_tokens = 512,
          -- How much the model may think: "low" | "medium" | "high" | "xhigh" | "max",
          -- or false for none. Only the claude provider sends it, lowered to what
          -- the model takes.
          -- effort = "low",
          -- string; overrides `provider` for completion requests only (false = unset).
          -- Pinned together with `model` below: a claude-* id must never be
          -- sent to another provider that "auto" happens to resolve.
          provider = "claude",
          -- string; overrides the provider's default model for completion requests only (false = unset).
          -- A small, cheap model for a latency-sensitive feature; without it
          -- completion would inherit `model.claude` above (claude-sonnet-5-5).
          model = "claude-haiku-5-5",
          -- keymap = {
          --   -- Insert mode: request a suggestion (manual mode only).
          --   trigger = "<C-\\><C-a>",
          --   -- Insert mode: insert the shown suggestion.
          --   accept = "<Tab>",
          --   -- Insert mode: clear the shown suggestion.
          --   dismiss = "<C-]>",
          -- },
        },

        -- vim.log.levels threshold of ai.nvim's own notifications.
        -- log_level = vim.log.levels.WARN,
        -- The agent that is active at startup, a name from `agents`; `false` is none.
        -- `:Ai agent <name>` changes it for the running session only (nothing is
        -- persisted, like `:Ai provider`).
        -- agent = false,
        -- Named presets of provider, model and system prompt that `:Ai agent <name>`
        -- switches between. Empty means no preset: every request resolves its
        -- provider, model and system prompt as before. Shape:
        --   agents = {
        --     review = { provider = "claude", model = "claude-opus-4-5", system = "You review code." },
        --     local_ = { provider = "ollama", model = "llama3" },
        --   }
        -- Every field is optional; a field a request sets itself always wins.
        -- agents = {},
        -- Guard rails for unattended bulk requests (`req.bulk`, see lua/ai/bulk.lua).
        -- `max_session_chars` caps the characters of ALL bulk requests of one
        -- Neovim session; `false` = no cap. `false`, not `nil`, so the key exists
        -- and is not reported as an unknown one.
        -- bulk = {
        --   max_session_chars = false,
        -- },
        -- Which providers this machine may use at all (see lua/ai/policy.lua). An
        -- empty `allowed` list means no restriction -- the default, and the
        -- behaviour before this option existed. Non-empty: `provider = "auto"`
        -- walks only these, and a request or `:Ai provider` naming anything else
        -- is refused (or has to be confirmed, see docs/configuration.md). `allowed`
        -- is the only key: another one (a typo such as `alowed`) refuses every
        -- provider, like a malformed `allowed` does -- and so does a top-level key
        -- that is `policy` itself misspelt (`polcy`, `policies`, within two edits).
        -- policy = {
        --   allowed = {},
        -- },
        -- Usage reporting (see lua/ai/usage.lua): after every request, one event with
        -- metadata only (provider, model, tokens, duration, outcome -- never any
        -- text) goes to a local ai-desktop server, which keeps the usage log and
        -- shows it on its dashboard. Opt-in: on, it is one extra network request per
        -- AI request, to a server the user runs themselves, so the default is off.
        -- `host` is the ai-desktop base URL; `false` (not `nil`, which would drop
        -- the key, see `completion.provider`) = the one the ai_desktop provider
        -- uses: AI_DESKTOP_HOST, else LOOMAI_HOST, else http://127.0.0.1:8080.
        -- usage = {
        --   report = false,
        --   host = false,
        -- },
      },
    }
  end)(),

  {
    "WKDSteve/buffer-ctx.nvim",
    cmd = {
      "Insert",
      "Copy",
      "Format",
      "Mark",
      "MarkLineToggle",
      "MarkLinesYank",
      "CopyFilepathAbsolute",
      "CopyFilepathRelative",
      "CopyFilepathRepos",
      "CopyFilepathEnv",
      "RevealInFm",
      "OpenInBrowser",
    },
    -- <leader>of/<leader>ob (reveal-in-filemanager / open-in-browser): picked
    -- over the more obvious <leader>fm because that key is already taken
    -- globally (Format file, see BINDINGS-RUNTIME-CHECKLIST.md); <leader>o* is
    -- free across the ecosystem. The keys listed here only lazy-load the
    -- plugin; the mappings themselves are installed by its setup() (see the
    -- keymap options in `opts`).
    keys = {
      "<leader>cnl",
      "<leader>cnm",
      "<leader>cnf",
      "<S-m>",
      "<C-p>",
      "<leader>of",
      "<leader>ob",
    },
    opts = {
      -- Lhs of the copy keymaps; `false` disables all of them.
      -- keymaps = {
      --   -- Copy path:line.
      --   location_copy = "<leader>cnl",
      --   -- Copy the module path.
      --   module_copy = "<leader>cnm",
      --   -- Copy the relative filepath.
      --   filepath_copy = "<leader>cnf",
      -- },
      -- Register the :Insert / :Copy / ... commands.
      -- commands = true,

      -- timestamp = {
      --   -- Emit every :Insert/:Copy timestamp in UTC without passing --utc
      --   -- (an explicit --utc still works).
      --   utc = false,
      -- },

      -- snippets = {
      --   -- VSCode-format snippet files loaded by :Insert snippet {name}.
      --   paths = {}, -- string[], e.g. { vim.fn.stdpath("config") .. "/snippets/lua.json" }
      -- },

      -- `false` switches the whole feature off.
      -- format = {
      --   -- Register the :Format command.
      --   enable = true,
      --   -- Name of that command.
      --   command = "Format",
      -- },

      -- `false` switches the whole feature off.
      -- mark = {
      --   -- Register the :Mark command.
      --   enable = true,
      --   -- Name of that command.
      --   command = "Mark",
      --   -- `false` disables the mark keymaps.
      --   keymaps = {
      --     -- Toggle a mark on the current line (or N lines with a count).
      --     toggle = "<S-m>",
      --     -- Yank all marked lines.
      --     yank = "<C-p>",
      --     -- clear = nil, -- string; remove every mark in the buffer (unset by default)
      --   },
      --   -- Appearance of the `default` category.
      --   sign = {
      --     text = "●",
      --     hl = "ErrorMsg",
      --   },
      --   -- Extra named appearances, used by `:Mark toggle {name}` / `:Mark yank {name}`.
      --   categories = {}, -- { name, text?, hl? }[], e.g. { { name = "todo", text = "●", hl = "WarningMsg" } }
      -- },

      -- `false` switches the whole feature off.
      -- reveal = {
      --   -- Register :RevealInFm / :OpenInBrowser.
      --   enable = true,
      --   -- `false` disables the reveal keymaps.
      --   keymaps = {
      --     -- Reveal the current buffer in the system file manager.
      --     fm = "<leader>of",
      --     -- Open the current buffer in the OS-registered application / browser.
      --     browser = "<leader>ob",
      --   },
      -- },

      -- Label the configured keymaps in which-key when it is installed.
      -- which_key = true,
    },
  },
}
