require("lunit")
discount = require("discount")

module("test discount", lunit.testcase, package.seeall)

function test_basic_conversion()
  assert_equal("<p>Hello World.</p>\n", discount("Hello World."))
end

function test_relaxed_emphasis()
  assert_equal("<p><em>Hello World</em>!</p>\n", discount("_Hello World_!"))
  assert_equal("<p>under_score this_stuff</p>\n", discount("under_score this_stuff"))

  local input = "_start _ foo_bar bar_baz _ end_ *italic* **bold** <a>_blah_</a>"
  local expected_out = "<p><em>start _ foo_bar bar_baz _ end</em> <em>italic</em> <strong>bold</strong> <a><em>blah</em></a></p>\n"
  assert_equal(expected_out, discount(input))
end

function test_nolinks()
  assert_equal("<p>[example](http://example.com)</p>\n", discount("[example](http://example.com)", "nolinks"))
  assert_equal('<p>&lt;a href="http://example.com">example</a></p>\n',
      discount('<a href="http://example.com">example</a>', "nolinks"))
end

function test_noimages()
  assert_equal("<p>![example](example.png)</p>\n", discount("![example](example.png)", "noimages"))
  assert_equal('<p>&lt;img src="example.png"/></p>\n', discount('<img src="example.png"/>', "noimages"))
end

function test_nopants()
  assert_equal('<p>&ldquo;quote&rdquo;</p>\n', discount('"quote"'))
  assert_equal('<p>"quote"</p>\n', discount('"quote"', "nopants"))
end

function test_nohtml()
  local expected = "<p>This should &lt;em>not&lt;/em> be allowed</p>\n"
  assert_equal(expected, discount("This should <em>not</em> be allowed", "nohtml"))
end

function test_cdata()
  assert_equal("&lt;p&gt;foo&lt;/p&gt;\n", discount("foo", "cdata"))
end
