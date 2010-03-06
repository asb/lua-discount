local exunit = require("exunit")
require("discount")

exunit.import()
local t = exunit.new("test discount")

function t.test_basic_conversion()
  assert_equal("<p>Hello World.</p>", discount("Hello World."))
end

function t.test_relaxed_emphasis()
  assert_equal("<p><em>Hello World</em>!</p>", discount("_Hello World_!"))
  assert_equal("<p>under_score this_stuff</p>", discount("under_score this_stuff"))

  local input = "_start _ foo_bar bar_baz _ end_ *italic* **bold** <a>_blah_</a>"
  local expected_out = "<p><em>start _ foo_bar bar_baz _ end</em> <em>italic</em> <strong>bold</strong> <a><em>blah</em></a></p>"
  assert_equal(expected_out, discount(input))
end

function t.test_nolinks()
  assert_equal("<p>[example](http://example.com)</p>", discount("[example](http://example.com)", "nolinks"))
  assert_equal('<p>&lt;a href=&ldquo;http://example.com&rdquo;>example</a></p>',
      discount('<a href="http://example.com">example</a>', "nolinks"))
end

function t.test_noimages()
  assert_equal("<p>![example](example.png)</p>", discount("![example](example.png)", "noimages"))
  assert_equal('<p>&lt;img src=&ldquo;example.png&rdquo;/></p>', discount('<img src="example.png"/>', "noimages"))
end

function t.test_nopants()
  assert_equal('<p>&ldquo;quote&rdquo;</p>', discount('"quote"'))
  assert_equal('<p>"quote"</p>', discount('"quote"', "nopants"))
end

function t.test_nohtml()
  local expected = "<p>This should &lt;em>not&lt;/em> be allowed</p>"
  assert_equal(expected, discount("This should <em>not</em> be allowed", "nohtml"))
end

function t.test_cdata()
  assert_equal("&lt;p&gt;foo&lt;/p&gt;", discount("foo", "cdata"))
end

function t.test_toc()
  local expected_out = '<h1 id="Level+1\">Level 1</h1>\n\n<h2 id="Level+2\">Level 2</h2>'
  local input = "# Level 1\n\n## Level 2\n\n"
  assert_equal(expected_out, discount(input, "toc"))
end

exunit.run_all()
