-- mako
--
-- Copyright (c) 2024, Michael Dowling
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.

--- Mako reactor is used to run tasks after a delay, at fixed intervals, or using coroutines.
local record Reactor

    --- A task to run on each tick, returning true to keep running, or false to stop.
    type Task = function(dt: number): boolean

    --- Creates a new reactor.
    --- @return Reactor.
    new: function(): Reactor

    --- Resets the reactor, removing all tasks.
    reset: function(Reactor: self)

    --- Adds a task to the reactor.
    --- @param task Task to add. The task accepts the delta time, and returns true to keep running, or false to stop.
    --- @return an opaque identifier that can be used to remove the task.
    run: function(Reactor: self, task: Task): any

    --- Runs an event after the given time.
    --- @param dt Time to wait before calling.
    --- @param f Function to call.
    --- @return an opaque identifier that can be used to remove the task.
    after: function(Reactor: self, dt: number, f: function()): any

    --- Adds a function to call every `duration` seconds.
    --- @param duration Time to wait between calls.
    --- @param f Function
    --- @return an opaque identifier that can be used to remove the task.
    every: function(Reactor: self, duration: number, f: function()): any

    --- Adds a coroutine task to the reactor.
    --- @param task Coroutine to add.
    --- @return an opaque identifier that can be used to remove the task.
    runCoroutine: function(Reactor: self, task: thread): any

    --- Update the reactor.
    --- @param dt Time since last update. The unit of time is applicaiton specific.
    update: function(Reactor: self, dt: number)

    --- Removes a task from the reactor using an opaque identifier.
    --- @param taskId Task to remove by identifier.
    remove: function(Reactor: self, taskId: any)

    _tasks: {Task}
end

local REACTOR_MT <const> = {__index = Reactor}

function Reactor.new(): Reactor
    return setmetatable({
        _tasks = {},
    }, REACTOR_MT)
end

function Reactor:reset()
    self._tasks = {}
end

function Reactor:run(task: Reactor.Task): any
    self._tasks[#self._tasks + 1] = task
    return task
end

function Reactor:after(delay: number, f: function()): any
    return self:run(function(dt: number): boolean
        delay = delay - dt
        if delay <= 0 then
            f()
            return false
        else
            return true
        end
    end)
end

function Reactor:every(duration: number, f: function()): any
    local delay = duration
    return self:run(function(dt: number): boolean
        duration = duration - dt
        if duration <= 0 then
            f()
            duration = delay
            return true
        else
            return true
        end
    end)
end

function Reactor:runCoroutine(task: thread): any
    return self:run(function(dt: number): boolean
        local success, result = coroutine.resume(task, dt)
        if not success then
            error(result)
        end
        return coroutine.status(task) ~= "dead"
    end)
end

function Reactor:update(dt: number)
    -- Iterate using a while loop since tasks can be removed during iteration.
    local i = 1
    while i <= #self._tasks do
        if self._tasks[i](dt) == false then
            table.remove(self._tasks, i)
        else
            i = i + 1
        end
    end
end

function Reactor:remove(taskId: any)
    for i = 1, #self._tasks do
        if self._tasks[i] == taskId then
            table.remove(self._tasks, i)
            return
        end
    end
end

return Reactor

