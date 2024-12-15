# mako

Task reactor for Lua, used to schedule and run tasks. Typed with
[Teal](https://github.com/teal-language/tl).

Mako is named after the Mako Reactor from Final Fantasy VII.

## Key features

* Designed to work with Love 2D, but can work with any event loop.
* Schedule functions to run after a delay.
* Schedule functions to run at a fixed interval.
* Schedule and run coroutines.
* Schedule tasks that run until they decide to stop.
* Can explicitly remove tasks.

## Usage

First, require the module:

```lua
local mako = require("mako")
```

Create a reactor:

```lua
local reactor = mako.new()
```

Run a function after a delay:

```lua
reactor:after(2, function()
    print("Hello, world!")
end)
```

In your main loop, update the reactor, passing in the time since the last
update. The unit of time is application specific; when using Love2D, it's the
delta time since the last update.

```lua
reactor:update(dt)
```

Run a function at a fixed interval:

```lua
reator:every(1, function()
    print("Hello, again!")
end)
```

Add a coroutine to the reactor:

```lua
reactor:add(coroutine.create(function()
    local count = 0
    while count < 2 do
        -- Receive `dt` from the resumption
        count = count + coroutine.yield() as number
        print("Coroutine time: ", count)
    end
end))
```

Add a task to the reactor. The task is called over and over with the time
since it was last called. The reactor stops calling the function when it
returns false.

```lua
reactor:addTask(function(dt: number): boolean
    print("Hello, task!")
    -- Return false to stop repeating the task.
    return false
end)
```

Removing a task from the reactor:

```lua
var handle = reactor:every(2, function()
    print("Called every 2 time unit until removed")
end)

reactor:remove(handle)
```

Every function that schedules a task returns a handle that can be used to
remove the function from the reactor.

## Installation

**Copy and paste**:

Copy and paste `src/mako.tl` or `src/mako.lua` into your project.

**Or use LuaRocks**:

```sh
luarocks install mako
```

## Contributing

The source code is written in Teal and compiled to Lua. The updated and
compiled Lua must be part of every code change to the Teal source code.
You can compile Teal to Lua and run tests using:

```sh
make
```
