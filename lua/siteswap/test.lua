local Class = require "luanode.class"
local EventEmitter = require "luanode.event_emitter"

require "luanode.utils"


---
-- Fake synchronous functions
--[[
local function Sync(test, fn, last)
	
	local function make_resumer(co)
		return function(...)
			return assert(coroutine.resume(co, ...))
		end
	end
	
	local function wrapper(...)
	fn(...)
	coroutine.yield()
	test:emit("done")
	end

	local co = coroutine.create(wrapper)

	--assert( coroutine.resume(co, make_resumer(co), coroutine.yield, last ) )
	assert( coroutine.resume(co, last, make_resumer(co), coroutine.yield ) )
end
--]]

local Test = Class.InheritsFrom(EventEmitter)

function Test:__init(name, fn, ...)
	--console.log("new test", name)
	
	local newTest = Class.construct(Test)
	
	newTest.name = name
	newTest.fn = fn
	
	return newTest
end

--[[
function Test:Run (callback)
	console.info("Will run test %q", self.name)
	
	local function make_resumer(co)
		return function(...)
			return assert(coroutine.resume(co, ...))
		end
	end
	
	local function wrapper(...)
	self.fn(self, ...)
	coroutine.yield()
	--test:emit("done")
	self:emit("done")
	end

	local co = coroutine.create(wrapper)
	local wait = make_resumer(co)

	
	local function last(fn)
		return function (emitter, err, results)
			fn(emitter, err, results)
			--next(self.name)
			console.color("green")
			console.log("Test %q completed on %s", self.name, os.date("%Y-%m-%d %H:%M%:%S"))
			console.reset_color()
			wait()
			callback()
		end
	end
	
	--assert( coroutine.resume(co, make_resumer(co), coroutine.yield, last ) )
	assert( coroutine.resume(co, last, wait, coroutine.yield ) )
	--Sync(self, self.fn, last)
end
--]]

function Test:Run (callback, env)
	console.info("Will run test %q", self.name)
	
	self.start_time = os.time()
	self.callback = callback

	local function last(fn)
		return function (emitter, err, results)
			if type(fn) == "function" then
				fn(emitter, err, results)
			end
			
			self:Done()
		end
	end
	
	self.Last = last
	
	self.fn(self, env)
end

function Test:Skip ()
	self.m_skipped = true
	self:callback()
end

function Test:Done ()
	self.end_time = os.time()
	
	self:emit("done")
	
	if not self.failed then
		self:emit("ok")
		console.color("green")
			console.log("Test %q completed ok. Took %d seconds", self.name, self.end_time - self.start_time)
		console.reset_color()
	else
		self:emit("failed")
		console.color("lightred")
			console.log("Test %q completed with errors. Took %d seconds", self.name, self.end_time - self.start_time)
		console.reset_color()
	end
	
	self:callback()
end










--[[--------------------------------------------------------------------------

    This file includes substantial portions of lunit 0.5.

    For Details about lunit look at: http://www.mroth.net/lunit/

    Author: Michael Roth <mroth@nessie.de>

    Copyright (c) 2004, 2006-2009 Michael Roth <mroth@nessie.de>

    Permission is hereby granted, free of charge, to any person 
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be 
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--]]--------------------------------------------------------------------------


local typenames = { "nil", "boolean", "number", "string", "table", "function", "thread", "userdata" }

local function format_arg(arg)
	local argtype = type(arg)
	if argtype == "string" then
		return "'"..arg.."'"
	elseif argtype == "number" or argtype == "boolean" or argtype == "nil" then
		return tostring(arg)
	else
		return "["..tostring(arg).."]"
	end
end

local function failure(testcase, name, usermsg, defaultmsg, ...)
	local errobj = {
		type    = __failure__,
		name    = name,
		msg     = string.format(defaultmsg,...),
		usermsg = usermsg
	}
	--console.error("Error in test case: %s -> %s", testcase.name, luanode.utils.inspect(errobj) )
	testcase.failed = testcase.failed or {}
	table.insert(testcase.failed, errobj)
	--error(errobj, 0)
end

for _, typename in ipairs(typenames) do
	local assert_typename = "assert_"..typename
	Test[assert_typename] = function(testcase, actual, msg)
		--stats.assertions = stats.assertions + 1
		--console.warn(assert_typename, actual, msg)
		local actualtype = type(actual)
		if actualtype ~= typename then
			--console.error(assert_typename, actualtype, typename)
			failure(testcase, assert_typename, msg, typename.." expected but was a "..actualtype )
		end
		return actual
	end
end

for _, typename in ipairs(typenames) do
	local assert_not_typename = "assert_not_"..typename
	Test[assert_not_typename] = function(testcase, actual, msg)
		--console.warn(assert_not_typename, actual, msg)
		--stats.assertions = stats.assertions + 1
		if type(actual) == typename then
			--console.error(assert_typename)
			failure(testcase, assert_not_typename, msg, typename.." not expected but was one" )
		end
	end
end


function Test:fail(msg)
	--stats.assertions = stats.assertions + 1
	failure(self, "fail", msg, "failure" )
end

function Test:assert(assertion, msg)
	--stats.assertions = stats.assertions + 1
	if not assertion then
		failure(self, "assert", msg, "assertion failed" )
	end
	return assertion
end

function Test:assert_true (actual, msg)
	--stats.assertions = stats.assertions + 1
	local actualtype = type(actual)
	if actualtype ~= "boolean" then
		failure(self, "assert_true", msg, "true expected but was a "..actualtype )
	end
	if actual ~= true then
		failure(self, "assert_true", msg, "true expected but was false" )
	end
	return actual
end


function Test:assert_false (actual, msg)
	--stats.assertions = stats.assertions + 1
	local actualtype = type(actual)
	if actualtype ~= "boolean" then
		failure(self, "assert_false", msg, "false expected but was a "..actualtype )
	end
	if actual ~= false then
		failure(self, "assert_false", msg, "false expected but was true" )
	end
	return actual
end

function Test:assert_equal (expected, actual, msg)
	--console.warn("assert_equal", expected, actual, msg)
	--stats.assertions = stats.assertions + 1
	if expected ~= actual then
		failure(self,  "assert_equal", msg, "expected %s but was %s", format_arg(expected), format_arg(actual) )
	end
	return actual
end

function Test:assert_not_equal(unexpected, actual, msg)
	--stats.assertions = stats.assertions + 1
	if unexpected == actual then
		failure(self, "assert_not_equal", msg, "%s not expected but was one", format_arg(unexpected) )
	end
	return actual
end

function Test:assert_match (pattern, actual, msg)
	--stats.assertions = stats.assertions + 1
	local patterntype = type(pattern)
	if patterntype ~= "string" then
		failure(self, "assert_match", msg, "expected the pattern as a string but was a "..patterntype )
	end
	local actualtype = type(actual)
	if actualtype ~= "string" then
		failure(self, "assert_match", msg, "expected a string to match pattern '%s' but was a %s", pattern, actualtype )
	end
	if not string.find(actual, pattern) then
		failure(self, "assert_match", msg, "expected '%s' to match pattern '%s' but doesn't", actual, pattern )
	end
	return actual
end

function Test:assert_not_match(pattern, actual, msg)
	--stats.assertions = stats.assertions + 1
	local patterntype = type(pattern)
	if patterntype ~= "string" then
		failure(self, "assert_not_match", msg, "expected the pattern as a string but was a "..patterntype )
	end
	local actualtype = type(actual)
	if actualtype ~= "string" then
		failure(self, "assert_not_match", msg, "expected a string to not match pattern '%s' but was a %s", pattern, actualtype )
	end
	if string.find(actual, pattern) then
		failure(self, "assert_not_match", msg, "expected '%s' to not match pattern '%s' but it does", actual, pattern )
	end
	return actual
end

function Test:assert_error(msg, func)
	--stats.assertions = stats.assertions + 1
	if func == nil then
		func, msg = msg, nil
	end
	local functype = type(func)
	if functype ~= "function" then
		failure(self, "assert_error", msg, "expected a function as last argument but was a "..functype )
	end
	local ok, errmsg = pcall(func)
	if ok then
		failure(self, "assert_error", msg, "error expected but no error occurred" )
	end
end

function Test:assert_error_match(msg, pattern, func)
	--stats.assertions = stats.assertions + 1
	if func == nil then
		msg, pattern, func = nil, msg, pattern
	end
	local patterntype = type(pattern)
	if patterntype ~= "string" then
		failure(self, "assert_error_match", msg, "expected the pattern as a string but was a "..patterntype )
	end
	local functype = type(func)
	if functype ~= "function" then
		failure(self, "assert_error_match", msg, "expected a function as last argument but was a "..functype )
	end
	local ok, errmsg = pcall(func)
	if ok then
		failure(self, "assert_error_match", msg, "error expected but no error occurred" )
	end
	local errmsgtype = type(errmsg)
	if errmsgtype ~= "string" then
		failure(self, "assert_error_match", msg, "error as string expected but was a "..errmsgtype )
	end
	if not string.find(errmsg, pattern) then
		failure(self, "assert_error_match", msg, "expected error '%s' to match pattern '%s' but doesn't", errmsg, pattern )
	end
end

function Test:assert_pass(msg, func)
	--stats.assertions = stats.assertions + 1
	if func == nil then
		func, msg = msg, nil
	end
	local functype = type(func)
	if functype ~= "function" then
		failure(self, "assert_pass", msg, "expected a function as last argument but was a %s", functype )
	end
	local ok, errmsg = pcall(func)
	if not ok then
		failure(self, "assert_pass", msg, "no error expected but error was: '%s'", errmsg )
	end
end

function Test:assert_deep_equal(expected, actual, msg)
	if type(expected) ~= "table" or type(actual) ~= "table" then
		failure(self,  "assert_equal", msg, "expected a table")
		return
	end
	
	if type(expected) ~= type(actual) then
		failure(self,  "assert_equal", msg, "expected %s but was %s", format_arg(type(expected)), format_arg(type(actual)) )
		return
	end
	
	for k,v in pairs(expected) do
		if actual[k] ~= v then
			failure(self,  "assert_equal", msg, "tables does not match (%s ~= %s)", format_arg(actual[k]), format_arg(v) )
		end
	end
	
	return actual
end

return Test
