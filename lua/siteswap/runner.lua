local Class = require "luanode.class"
local EventEmitter = require "luanode.event_emitter"
local Test = require "siteswap.test"
local console = console

local color_lightred = console.getColor("lightred")
local color_reset = console.getResetColor()

require "luanode.utils"

local Runner = Class.InheritsFrom(EventEmitter)


local private = {}

private.TestsDone = function (runner)
	local with_errors = false
	for _, test in ipairs(runner.m_tests) do
		
		if test.failed and #test.failed > 0 then
			runner.log(color_lightred .. "Test failed: %s\n%s", test.name, luanode.utils.inspect(test.failed) .. color_reset)
			with_errors = true
		end
	end

	runner:emit("done", with_errors)
end


function Runner:__init(options, ...)
	
	local runner = Class.construct(Runner, ...)
	
	runner.m_tests = {}

	if options then
		if options.log then
			runner.log = options.log
		end
	end
	
	runner.log = runner.log or console.log
	
	return runner
end

function Runner:AddTest (name, test_function)
	local test = Test(name, test_function, { log = self.log })
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
