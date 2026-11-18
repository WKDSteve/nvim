-- TESTS/cdx/rule_drift_spec.lua -- no working rule is written out twice.
--
-- The wording of a working rule lives once in the rules vault ($RULES_VAULT/rulesets/arbeit/_rules/<FAMILY>/<ID>.md).
-- CLAUDE.global.md, the prompt templates and the repo templates cite it by id (rule_refs_spec.lua) and keep only a
-- short core of their own. This spec catches the copy that creeps back: every sentence of a rule's text (from the
-- heading to `Begründung:`/`Beleg:`), normalized and at least MIN_LEN characters long, must not appear in one of those
-- files. The old long templates `templates/PROMPT/*_standalone.md` repeat the rules on purpose and are left out.
-- Without a rules vault (the CI of this config has none) the spec ends as n/a after testing its own detector.

-- Long enough that an id citation ("siehe `GIT-05`") or a short core line does not count, short enough that one
-- copied clause of a rule does. Measured 2026-11-18: at 40 the deliberate short cores of CLAUDE.global.md and the
-- templates (rule titles, "leer oder default = privater Rechner (STEVESPC)", 47 chars) start to match; at 50 only
-- real copies do.
local MIN_LEN = 50

-- Deliberate verbatim cores: { file basename, rule id, reason }. Keep it short; every entry needs a reason.
local ALLOWED = {}

---@param s string
---@return string
local function normalize_inline(s)
  s = s:gsub("`", "")
  s = s:gsub("%*", "")
  for _, q in ipairs({ "„", "“", "”", "‚", "‘", "’", '"', "«", "»" }) do
    s = s:gsub(vim.pesc(q), "")
  end
  s = s:gsub("%s+", " ")
  return vim.trim(s):lower()
end

---One markdown line without its block markup (list bullet, numbering, heading, quote, checkbox).
---@param line string
---@return string
local function normalize_line(line)
  line = line:gsub("^%s*>%s?", "")
  line = line:gsub("^%s*#+%s+", "")
  line = line:gsub("^%s*[-+*]%s+", "")
  line = line:gsub("^%s*%d+[.)]%s+", "")
  line = line:gsub("^%[[ xX]%]%s+", "")
  return normalize_inline(line)
end

---A file as one normalized string plus the offset where each source line starts.
---@param body string
---@return string text, {[1]: integer, [2]: integer}[] starts (offset, line number)
local function flatten(body)
  local parts, starts, len = {}, {}, 0
  local n = 0
  for line in (body .. "\n"):gmatch("([^\n]*)\n") do
    n = n + 1
    local s = normalize_line(line:gsub("\r$", ""))
    if s ~= "" then
      if len > 0 then
        parts[#parts + 1] = " "
        len = len + 1
      end
      starts[#starts + 1] = { len + 1, n }
      parts[#parts + 1] = s
      len = len + #s
    end
  end
  return table.concat(parts), starts
end

---@param starts {[1]: integer, [2]: integer}[]
---@param pos integer
---@return integer
local function line_at(starts, pos)
  local line = 1
  for _, st in ipairs(starts) do
    if st[1] > pos then
      break
    end
    line = st[2]
  end
  return line
end

---The rule text of one rule file: heading title plus the body up to `Begründung:`/`Beleg:`.
---@param body string
---@return string
local function rule_text(body)
  local out, inside = {}, false
  for line in (body .. "\n"):gmatch("([^\n]*)\n") do
    line = line:gsub("\r$", "")
    if not inside then
      local title = line:match("^#+%s.-—%s*(.+)$")
      if title then
        inside = true
        out[#out + 1] = title .. "."
      end
    elseif line:match("^Begründung:") or line:match("^Beleg:") or line:match("^%-%-%-%s*$") then
      break
    else
      out[#out + 1] = line
    end
  end
  return table.concat(out, "\n")
end

---The sentences (and colon/semicolon clauses) of a rule text at least MIN_LEN long.
---@param text string
---@return string[]
local function sentences(text)
  local flat = flatten(text)
  local out = {}
  for piece in (flat .. " "):gmatch("(.-[.!?;:])%s") do
    piece = vim.trim(piece:gsub("[.!?;:]$", ""))
    if #piece >= MIN_LEN then
      out[#out + 1] = piece
    end
  end
  -- the tail after the last delimiter
  local tail = vim.trim(flat:match("[.!?;:]%s([^.!?;:]*)$") or "")
  if #tail >= MIN_LEN then
    out[#out + 1] = tail
  end
  return out
end

---@param rules {id: string, text: string}[]
---@param files {path: string, body: string}[]
---@return {path: string, line: integer, id: string, sentence: string}[]
local function find_drift(rules, files)
  local hits = {}
  for _, f in ipairs(files) do
    local text, starts = flatten(f.body)
    for _, r in ipairs(rules) do
      for _, s in ipairs(sentences(r.text)) do
        local pos = text:find(s, 1, true)
        if pos then
          hits[#hits + 1] = { path = f.path, line = line_at(starts, pos), id = r.id, sentence = s }
        end
      end
    end
  end
  return hits
end

return function(H)
  local ok, eq = H.ok, H.eq

  -- the detector itself, on a made-up rule
  local fake_rule = table.concat({
    "---",
    "id: TEST-01",
    "---",
    "",
    "#### `TEST-01` — Kurz",
    "",
    "Uncommittete Änderungen, die nicht von dir sind, nie committen, zurücksetzen,",
    "formatieren oder **stashen** (`git status` prüfen). Kurzer Satz.",
    "",
    "Begründung: diese Begründung ist lang genug, um ohne Grenze als Dublette gemeldet zu werden.",
  }, "\n")
  local fake = { { id = "TEST-01", text = rule_text(fake_rule) } }
  eq(#sentences(fake[1].text), 1, "only the long sentence counts, the reason is not rule text")
  local copied = "# Kern\n\nSiehe `TEST-01`.\n\n- Uncommittete Änderungen, die nicht von dir sind,\n"
    .. "  nie committen, zurücksetzen, formatieren oder stashen (git status prüfen).\n"
  local hits = find_drift(fake, { { path = "x.md", body = copied } })
  eq(#hits, 1, "a copied sentence is reported despite line breaks, bullet and markup")
  eq(hits[1].line, 5, "with the line where it starts")
  eq(hits[1].id, "TEST-01", "and the rule id")
  eq(
    #find_drift(fake, { { path = "y.md", body = "Siehe `TEST-01` (nie stashen).\n" } }),
    0,
    "a citation is no copy"
  )
  eq(#find_drift(fake, {
    {
      path = "z.md",
      body = "diese Begründung ist lang genug, um ohne Grenze als Dublette gemeldet zu werden",
    },
  }), 0, "the reason of a rule may be quoted")

  -- From this file, not stdpath("config"): in a worktree that is the main checkout.
  local spec = debug.getinfo(1, "S").source:sub(2)
  local root =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(spec, ":p")))))
  local cdx = root .. "/docs/NOTES/CDX"
  local prompt = cdx .. "/templates/PROMPT"

  local files = { { path = cdx .. "/CLAUDE.global.md" } }
  for name, kind in vim.fs.dir(prompt) do
    if kind == "file" and name:match("%.md$") and not name:match("_standalone%.md$") then
      files[#files + 1] = { path = prompt .. "/" .. name }
    end
  end
  for name, kind in vim.fs.dir(cdx .. "/templates") do
    if kind == "directory" and H.exists(cdx .. "/templates/" .. name .. "/CLAUDE.md") then
      files[#files + 1] = { path = cdx .. "/templates/" .. name .. "/CLAUDE.md" }
    end
  end
  for _, f in ipairs(files) do
    f.body = H.read(f.path)
    ok(f.body ~= nil, "readable: " .. f.path)
  end
  ok(#files >= 10, "CLAUDE.global.md, the prompt templates and the repo templates are checked")

  local vault = vim.env.RULES_VAULT
  if not vault or vault == "" or vim.fn.isdirectory(vault .. "/rulesets/arbeit/_rules") ~= 1 then
    print("n/a  no rules vault ($RULES_VAULT) here: no rule text to compare against")
    return
  end
  local dir = vim.fs.normalize(vault) .. "/rulesets/arbeit/_rules"
  local rules = {}
  for fam, kind in vim.fs.dir(dir) do
    if kind == "directory" then
      for name, k in vim.fs.dir(dir .. "/" .. fam) do
        local id = k == "file" and name:match("^(%u+%-%d+)%.md$")
        if id then
          rules[#rules + 1] =
            { id = id, text = rule_text(H.read(dir .. "/" .. fam .. "/" .. name) or "") }
        end
      end
    end
  end
  ok(#rules >= 50, "the rules of the vault are read")
  local counted = 0
  for _, r in ipairs(rules) do
    counted = counted + #sentences(r.text)
  end
  ok(counted >= #rules, "the rules yield sentences to compare")

  -- positive test on the real data: a sentence of GIT-05 slipped into a copy of CLAUDE.global.md is reported
  local git05
  for _, r in ipairs(rules) do
    git05 = r.id == "GIT-05" and r or git05
  end
  ok(git05, "GIT-05 is in the vault")
  local planted = sentences(git05.text)[1]
  local copy = { path = files[1].path, body = files[1].body .. "\n- " .. planted .. ".\n" }
  local seen = false
  for _, h in ipairs(find_drift({ git05 }, { copy })) do
    seen = seen or h.id == "GIT-05"
  end
  ok(seen, "a planted copy of GIT-05 is reported")

  local report = {}
  for _, h in ipairs(find_drift(rules, files)) do
    local allowed = false
    for _, a in ipairs(ALLOWED) do
      allowed = allowed or (a[1] == vim.fs.basename(h.path) and a[2] == h.id)
    end
    if not allowed then
      report[#report + 1] = ("%s:%d copies %s: %s"):format(
        h.path:sub(#root + 2),
        h.line,
        h.id,
        h.sentence
      )
    end
  end
  ok(#report == 0, "rule text is cited by id, not copied:\n" .. table.concat(report, "\n"))
end
