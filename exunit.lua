local _M = {}

local stats = {
  assertions  = 0,
  passed      = 0,
  failed      = 0,
  errored     = 0
}

local test_cases = {}

local state
local function reset_state()
  state = {
    test_num = 0,
    test_name = nil,
    test_hadfailure = false,
    testcase_name = nil,
    tc_assertions = 0,
    tc_passed = 0,
    tc_failed = 0,
    tc_errored = 0
  }
end
reset_state()

local function count_assertion()
  state.tc_assertions = state.tc_assertions + 1
end

local function count_pass()
  state.tc_passed = state.tc_passed + 1
end

local function count_fail()
  state.tc_failed = state.tc_failed + 1
end

local function count_error()
  state.tc_errored = state.tc_errored + 1
end

local function failure(func, usermsg, unitmsg, ...)
  state.test_hadfailure = true
  unitmsg = unitmsg:format(...)
  local info = debug.getinfo(3, "Snl")
  print(("  %d) Failure (%s):"):format(state.test_num, state.test_name))
  print(("%s:%d: %s"):format(info.short_src, info.currentline, unitmsg))
  if (usermsg) then
    print(("%s:%d: %s"):format(info.short_src, info.currentline, usermsg))
  end
  print("")
end

function _M.assert(assertion, msg)
  count_assertion()
  if not assertion then
    failure("assert", msg, "assertion failed")
  end
  return assertion
end


function _M.assert_equal(expected, actual, msg)
  count_assertion()
  if expected ~= actual then
    failure("assert_equal", msg, "expected '%s' but was '%s'", expected, actual)
  end
  return actual
end

function _M.assert_true(actual, msg)
  count_assertion()
  local actualtype = type(actual)
  if actualtype ~= "boolean" then
    failure("assert_true", msg, "true expected but was a "..actualtype)
  end
  if actual ~= true then
    failure("assert_true", msg, "true expected but was false")
  end
  return actual
end

function _M.assert_false(actual, msg)
  count_assertion()
  local actualtype = type(actual)
  if actualtype ~= "boolean" then
    failure("assert_false", msg, "false expected but was a "..actualtype)
  end
  if actual ~= false then
    failure("assert_false", msg, "false expected but was true")
  end
  return actual
end

function _M.assert_not_equal(unexpected, actual, msg)
  count_assertion()
  if unexpected == actual then
    failure("assert_not_equal", msg, "'%s' not expected but was one", unexpected)
  end
  return actual
end

function _M.assert_match(pattern, actual, msg)
  count_assertion()
  if not type(pattern) == "string" then
    failure("assert_match", msg, "expected the pattern as a string but was '%s'", pattern)
  end
  if not type(actual) == "string" then
    failure("assert_match", msg, "expected a string to match pattern '%s' but was '%s'", pattern, actual)
  end
  if not actual:find(pattern) then
    failure("assert_match", msg, "expected '%s' to match pattern '%s' but doesn't", actual, pattern)
  end
  return actual
end

function _M.assert_not_match(pattern, actual, msg)
  count_assertion()
  if not type(pattern) == "string" then
    failure("assert_not_match", msg, "expected the pattern as a string but was '%s'", pattern)
  end
  if not type(actual) == "string" then
    failure( "assert_not_match", msg, "expected a string to not match pattern '%s' but was '%s'", pattern, actual)
  end
  if actual:find(pattern) then
    failure("assert_not_match", msg, "expected '%s' to not match pattern '%s' but it does", actual, pattern)
  end
  return actual
end

function _M.assert_error(msg, func)
  count_assertion()
  if func == nil then
    func, msg = msg, nil
  end
  local functype = type(func)
  if functype ~= "function" then
    failure("assert_error", msg, "expected a function as last argument but was a "..functype)
  end
  local ok, errmsg = pcall(func)
  if ok then
    failure( "assert_error", msg, "error expected but no error occurred" )
  end
end

function _M.assert_pass(msg, func)
  count_assertion()
  if func == nil then
    func, msg = msg, nil
  end
  local functype = type(func)
  if functype ~= "function" then
    failure("assert_pass", msg, "expected a function as last argument but was a %s", functype)
  end
  local ok, errmsg = pcall(func)
  if not ok then
    failure( "assert_pass", msg, "no error expected but error was: '%s'", errmsg )
  end
end

local typenames = { "nil", "boolean", "number", "string", "table", "function", "thread", "userdata" }
-- ex.assert_typename functions
for _, typename in ipairs(typenames) do
  local assert_typename = "assert_"..typename
  _M[assert_typename] = function(actual, msg)
    count_assertion()
    local actualtype = type(actual)
    if actualtype ~= typename then
      failure(assert_typename, msg, typename.." expected but was a "..actualtype)
    end
    return actual
  end
end


-- ex.assert_not_typename functions
for _, typename in ipairs(typenames) do
  local assert_not_name = "assert_not_"..typename
  _M[assert_not_name] = function(actual, msg)
    count_assertion()
    if type(actual) == typename then
      failure( assert_not_typename, msg, typename.." not expected but was one" )
    end
  end
end

function _M.import()
  local env = getfenv(1)
  for k, v in pairs(_M) do
    if (type(k) == "string" and k:match("^assert_")) then
      env[k] = v
    end
  end
end

function _M.new(name)
  assert(name and type(name) == "string", "test case must have a name")
  local tc = {}
  test_cases[tc] = name
  test_cases[#test_cases+1] = tc
  return tc
end

local function update_stats()
  for _, v in ipairs({"assertions", "passed", "failed", "errored"}) do
    stats[v] = stats[v] + state["tc_"..v]
  end
end

function _M.run(tc)
  reset_state()
  local function istest(k, v)
    return type(k) == "string" and type(v) == "function" and k:match("^test_")
  end

  local count = 0
  for k, v in pairs(tc) do
    if istest(k, v) then
      count = count+1
    end
  end

  state.testcase_name = test_cases[tc]
  print(("# Running test case '%s' (%d tests)\n"):format(test_cases[tc], count))
  for k, v in pairs(tc) do
    if istest(k, v) then
      state.test_num = state.test_num + 1
      state.test_name = k
      do_test(v, tc.setup, tc.teardown)
    end
  end

  print(state.tc_assertions.." assertions checked")
  print(("Finished test case '%s'. %s tests (%d passed, %d failed, %d errored)\n"):format(state.testcase_name, count, state.tc_passed, state.tc_failed, state.tc_errored))
  update_stats()
end

function _M.run_all()
  print(("Loaded testsuite with %d testcases\n"):format(#test_cases))
  for _, tc in ipairs(test_cases) do
    _M.run(tc)
  end
  print("")
end

function do_test(func, setup, teardown)
  local function docall(f)
    if (type(f) ~= "function") then
      return true
    end

    local succ, tb = xpcall(f, debug.traceback)
    if not succ then
      count_error()
      print(("  %d) Error (%s):"):format(state.test_num, state.test_name))
      print(tb, "\n")
      return false
    end
    return true
  end

  state.test_hadfailure = false
  if (not docall(setup)) or (not docall(func)) or not (docall(teardown)) then
    return
  else
    if state.test_hadfailure then
      count_fail()
    else
      count_pass()
    end
  end
end

return _M
