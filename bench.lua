require('markdown')
discount = require('discount')

local function read_file(fn)
  local file = assert(io.open(fn))
  local contents = assert(file:read('*a'))
  file:close()
  return contents
end

text = {}

for fn in io.popen('find Tests -type f -name "*.text"'):lines() do
  text[fn] = read_file(fn)
end

function test_implementation(mkd, name, rep)
  rep = rep or 100
  print("Testing "..name)
  local start_time = os.clock()
  for i=1, rep do
    for fn, contents in pairs(text) do
      print(mkd(contents))
    end
  end
  local end_time = os.clock()
  print("Time: "..(end_time-start_time))
end

test_implementation(discount, "lua-discount")
print('')
test_implementation(markdown, "Markdown.lua")
