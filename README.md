
# siteswap #

**Siteswap** is a simple asynchronous test framework for [LuaNode][2], based on [lunit][3].

Siteswap is...
> a notation used to describe juggling patterns..

(taken from [Wikipedia][1]).

And writing tests for asynchronous code is mostly juggling stuff in the air, so...

## What does it look like? #

Since it is based on [lunit][3], **Siteswap** tests look very similar.

```lua
local Runner = require "siteswap.runner"
local Test = require "siteswap.test"
local runner = Runner()

runner:AddTest("equality", function(test)
  test:assert_equal(12345, 12345)
  test:Done()
end)

runner:AddTest("FOO", function(test)
  setTimeout(function()
    test:assert_equal("hello", "hello")
  end, 1000)
  
  setTimeout(test:Last(function()
    console.log("something will happen in two seconds")
  end), 2000)
end)

runner:Run()

process:loop()
```

## Installation #
Just copy all files to Lua's path. A rockspec file to be used with [LuaRocks][5] will be provided soon.
  
## Documentation #
Until I write some proper documentation you can take a look at [redis-luanode][4] tests as a guide. In fact, **Siteswap** was written in order to test it.

## Status #
I plan to provide some kind of output compatible with Jenkins. Also, no stack traces are recorded when an assertion fails, yet.

## Acknowledgments #
I'd like to acknowledge the work of the following people:

 - Michael Roth, for his work with [lunit][3].
 - [Federico Silva][6], who came up with the name :).

 
## License #
**Siteswap** is available under the MIT license.


[1]: http://en.wikipedia.org/wiki/Siteswap
[2]: https://github.com/ignacio/LuaNode
[3]: http://www.nessie.de/mroth/lunit/
[4]: https://github.com/ignacio/redis-luanode/blob/github/test/test.lua
[5]: http://luarocks.org/
[6]: https://github.com/fedesilva/
