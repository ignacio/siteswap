package = "siteswap"
version = "git-1"
source = {
	url = "git://github.com/ignacio/siteswap.git",
	branch = "master"
}
description = {
	summary = "SiteSwap, a simple asynchronous test framework based on lunit.",
	detailed = [[
SiteSwap allows to write tests for LuaNode involving asynchronous operations, in a style similar to lunit.
]],
	license = "MIT/X11",
	homepage = "https://github.com/ignacio/siteswap"
}
dependencies = {
	"lua ~> 5.1"
}

build = {
  	type = "none",
	install = {
  		lua = {
			["siteswap.runner"] = "lua/siteswap/runner.lua",
			["siteswap.test"] = "lua/siteswap/test.lua",
			["siteswap.barrier"] = "lua/siteswap/barrier.lua",
  		}
	}
}
