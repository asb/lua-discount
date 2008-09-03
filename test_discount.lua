require("lunit")
discount = require("discount")

module("test discount", lunit.testcase, package.seeall)

function test_basic_conversion()
  assert_equal("<p>Hello World.</p>\n", discount("Hello World."))
end

function test_relaxed_emphasis()
  assert_equal("<p><em>Hello World</em>!</p>\n", discount("_Hello World_!"))

  local input = "_start _ foo_bar bar_baz _ end_ *italic* **bold** <a>_blah_</a>"
  local expected_out = "<p><em>start _ foo_bar bar_baz _ end</em> <em>italic</em> <strong>bold</strong> <a><em>blah</em></a></p>\n"
  assert_equal(expected_out, discount(input))
end

function test_nohtml()
  local expected = "<p>This should &lt;em>not&lt;/em> be allowed</p>\n"
  assert_equal(expected, discount("This should <em>not</em> be allowed", "nohtml"))
end
