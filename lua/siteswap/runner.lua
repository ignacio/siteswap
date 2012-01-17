local Class = require "luanode.class"
local EventEmitter = require "luanode.event_emitter"
local Test = require "siteswap.test"
require "luanode.utils"

local Runner = Class.InheritsFrom(EventEmitter)


local private = {}

private.TestsDone = function (runner)
	local with_errors = false
	for _, test in ipairs(runner.m_tests) do
		
		if test.failed and #test.failed > 0 then
			console.error("Test failed: %s\n%s", test.name, luanode.utils.inspect(test.failed))
			with_errors = true
		end
	end

	runner:emit("done", with_errors)
end


function Runner:__init(...)
	
	local runner = Class.construct(Runner, ...)
	
	runner.m_tests = {}
	
	return runner
end

function Runner:AddTest (name, test_function)
	local test = Test(name, test_function)
	table.insert(self.m_tests, test)
	return test
end


function Runner:Run (env)
	local iterator, tests, first_index = ipairs(self.m_tests)
	
	local next_index, test = iterator(self.m_tests, first_index)

	local function run_next()
		self:emit("after_test", test)
		next_index, test = iterator(tests, next_index)
		if test then
			self:emit("before_test", test)
			test:Run(run_next, env)
		else
			private.TestsDone(self)
		end
	end

	if next_index then
		self:emit("before_test", test)
		test:Run(run_next, env)
	else
		private.TestsDone(self)
	end
end


return Runner
