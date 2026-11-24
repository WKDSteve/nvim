-- TESTS/ui_statusline_acronyms_slot_spec.lua -- the text of the personal acronym slot
-- (config/ui_statusline/acronyms_slot.lua): every file it lists exists in the WKDBook-Tricentis repo,
-- so a renamed folder (Cheatsheets/Cheetsheets) no longer drops one silently, and the short-term
-- collection `Terminologie/Terminologie.md` is part of it.

return function(H)
  local eq = H.eq
  local slot = require("config.ui_statusline.acronyms_slot")

  eq(
    vim.tbl_contains(slot.sources, "Terminologie/Terminologie.md"),
    true,
    "the short-term collection is shown too"
  )

  local root = vim.env.REPOS_DIR
  local base = root and root ~= "" and vim.fs.joinpath(root, "WKDBook-Tricentis") or nil
  if not base or vim.fn.isdirectory(base) == 0 then
    print("n/a  no WKDBook-Tricentis checkout under $REPOS_DIR")
    return
  end
  for _, rel in ipairs(slot.sources) do
    eq(vim.fn.filereadable(vim.fs.joinpath(base, rel)), 1, "listed file exists: " .. rel)
  end
end
