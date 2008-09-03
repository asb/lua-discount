require("Benchmark")

require('markdown')
discount = require('discount')


local function read_file(fn)
  local file = assert(io.open(fn))
  local contents = assert(file:read('*a'))
  file:close()
  return contents
end

local bench = Benchmark:new()

local REPS = 100
local input = read_file("syntax.text")
print("Benchmarking using http://daringfireball.net/projects/markdown/syntax.text\n")

bench:add("lua-discount", function()
  for i=1, REPS do
    discount(input)
  end
end)

bench:add("markdown.lua", function()
  for i=1, REPS do
    markdown(input)
  end
end)

bench:run()
