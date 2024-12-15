







local Reactor = {}












































local REACTOR_MT = { __index = Reactor }

function Reactor.new()
   return setmetatable({
      _tasks = {},
   }, REACTOR_MT)
end

function Reactor:reset()
   self._tasks = {}
end

function Reactor:run(task)
   self._tasks[#self._tasks + 1] = task
   return task
end

function Reactor:after(delay, f)
   return self:run(function(dt)
      delay = delay - dt
      if delay <= 0 then
         f()
         return false
      else
         return true
      end
   end)
end

function Reactor:every(duration, f)
   local delay = duration
   return self:run(function(dt)
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

function Reactor:runCoroutine(task)
   return self:run(function(dt)
      local success, result = coroutine.resume(task, dt)
      if not success then
         error(result)
      end
      return coroutine.status(task) ~= "dead"
   end)
end

function Reactor:update(dt)

   local i = 1
   while i <= #self._tasks do
      if self._tasks[i](dt) == false then
         table.remove(self._tasks, i)
      else
         i = i + 1
      end
   end
end

function Reactor:remove(taskId)
   for i = 1, #self._tasks do
      if self._tasks[i] == taskId then
         table.remove(self._tasks, i)
         return
      end
   end
end

return Reactor
