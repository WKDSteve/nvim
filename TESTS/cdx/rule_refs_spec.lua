-- TESTS/cdx/rule_refs_spec.lua -- CLAUDE.global.md and the short templates cite working rules by id.
--
-- The rule text lives once in the rules vault ($RULES_VAULT/rulesets/arbeit/_rules/<FAMILY>/<ID>.md); the global
-- CLAUDE.md, the repo templates and the prompt templates only cite ids (`CI-11`, `FALCON-01..13`). A cited id that the
-- vault does not have points nowhere, so every one must exist. Every `*_standalone.md` prompt template keeps a short
-- counterpart under the old name, and the short one names its standalone fallback.

return function(H)
  local ok = H.ok

  -- From this file, not stdpath("config"): in a worktree that is the main checkout.
  local spec = debug.getinfo(1, "S").source:sub(2)
  local root =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(spec, ":p")))))
  local cdx = root .. "/docs/NOTES/CDX"
  local prompt = cdx .. "/templates/PROMPT"

  -- the short templates and their standalone fallbacks
  local short = {}
  for name, kind in vim.fs.dir(prompt) do
    local stem = kind == "file" and name:match("^(.+)_standalone%.md$")
    if stem then
      local body = H.read(prompt .. "/" .. stem .. ".md")
      ok(body ~= nil, stem .. "_standalone.md has a short counterpart " .. stem .. ".md")
      ok(
        (body or ""):find(stem .. "_standalone.md", 1, true),
        stem .. ".md names its fallback " .. stem .. "_standalone.md"
      )
      short[#short + 1] = prompt .. "/" .. stem .. ".md"
    end
  end
  ok(#short >= 4, "Base, base_workstation, full and tasks have a standalone version")

  -- the files that cite ids
  local files = { cdx .. "/CLAUDE.global.md" }
  vim.list_extend(files, short)
  for name, kind in vim.fs.dir(prompt) do
    if kind == "file" and name:match("^review.*%.md$") then
      files[#files + 1] = prompt .. "/" .. name
    end
  end
  for name, kind in vim.fs.dir(cdx .. "/templates") do
    if kind == "directory" and H.exists(cdx .. "/templates/" .. name .. "/CLAUDE.md") then
      files[#files + 1] = cdx .. "/templates/" .. name .. "/CLAUDE.md"
    end
  end

  local FAMILIES = "ALLG MASCHINE FALCON GIT REVIEW TASKS DOKU FALLEN CI"
  local cited = {} ---@type table<string, string> id -> first file
  for _, file in ipairs(files) do
    local body = H.read(file) or ""
    -- `FAMILY-01` and ranges `FAMILY-01..13`; a range cites both ends
    for fam, a, b in body:gmatch("`(%u+)%-(%d%d)%.%.(%d%d)`") do
      if FAMILIES:find(fam, 1, true) then
        cited[fam .. "-" .. a] = cited[fam .. "-" .. a] or file
        cited[fam .. "-" .. b] = cited[fam .. "-" .. b] or file
      end
    end
    for fam, n in body:gmatch("`(%u+)%-(%d%d)`") do
      if FAMILIES:find(fam, 1, true) then
        cited[fam .. "-" .. n] = cited[fam .. "-" .. n] or file
      end
    end
  end
  ok(cited["GIT-04"] and cited["MASCHINE-03"], "the detector sees the ids of CLAUDE.global.md")
  ok(cited["FALCON-13"], "and the end of a range")

  local vault = vim.env.RULES_VAULT
  if not vault or vault == "" or vim.fn.isdirectory(vault .. "/rulesets/arbeit/_rules") ~= 1 then
    print("n/a  no rules vault ($RULES_VAULT) here: the cited ids are not checked against it")
    return
  end
  local rules = vim.fs.normalize(vault) .. "/rulesets/arbeit/_rules"
  for id, file in pairs(cited) do
    local fam = id:match("^(%u+)")
    ok(
      H.exists(rules .. "/" .. fam .. "/" .. id .. ".md"),
      id .. " (cited in " .. vim.fs.basename(file) .. ") exists in the rules vault"
    )
  end
  -- positive test of the check itself: an id the vault cannot have
  ok(not H.exists(rules .. "/CI/CI-99.md"), "a made-up id is reported missing")
end
