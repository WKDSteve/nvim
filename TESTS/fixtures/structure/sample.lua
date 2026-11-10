local function walk(items)
  for i = 1, #items do
    if items[i] > 1 then
      print(items[i])
    end
  end
end

local config = {
  server = {
    tls = {
      cert = "a",
    },
  },
}

return { walk = walk, config = config }
