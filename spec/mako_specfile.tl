global describe: function(string, function)
global it: function(string, function)

local mako <const> = require("mako")

describe("mako", function()
    describe("new", function()
        it("works", function()
            mako.new()
        end)
    end)

    describe("after", function()
        it("can run after delay", function()
            local reactor = mako.new()
            local ran = false
            reactor:after(1, function()
                ran = true
            end)

            reactor:update(0.5)
            assert(not ran)
            reactor:update(0.5)
            assert(ran)
        end)

        it("can remove by id", function()
            local reactor = mako.new()
            local ran = false
            local id = reactor:after(1, function()
                ran = true
            end)

            reactor:remove(id)
            reactor:update(1)
            assert(not ran)
        end)
    end)

    describe("every", function()
        it("can run on an interval", function()
            local reactor = mako.new()
            local ran = 0
            reactor:every(1, function()
                ran = ran + 1
            end)

            reactor:update(0.5)
            assert(ran == 0)
            reactor:update(0.5)
            assert(ran == 1)
            reactor:update(0.5)
            assert(ran == 1)
            reactor:update(0.5)
            assert(ran == 2)
        end)
    end)

    describe("run", function()
        it("can run a function", function()
            local reactor = mako.new()
            local ran: number = 0
            reactor:run(function(dt: number): boolean
                ran = ran + dt
                return ran < 3
            end)

            reactor:update(0.5)
            assert(ran == 0.5)
            reactor:update(0.5)
            assert(ran == 1)
            reactor:update(1)
            assert(ran == 2)
            reactor:update(1)
            assert(ran == 3)
            reactor:update(1)
            assert(ran == 3)
        end)
    end)

    describe("addCoroutine", function()
        it("can add a coroutine", function()
            local reactor = mako.new()
            local dts: {number} = {}
            local task = coroutine.create(function()
                local ran: number = 0
                while ran < 2 do
                    local dt = coroutine.yield() as number
                    dts[#dts + 1] = dt
                    ran = ran + dt
                end
            end)

            reactor:runCoroutine(task)
            reactor:update(1)
            assert(#dts == 0) -- hasn't been resumed yet.
            reactor:update(1)
            assert(#dts == 1) -- first resumption.
            reactor:update(1)
            assert(#dts == 2)

            assert(dts[1] == 1)
            assert(dts[2] == 1)
        end)
    end)
end)

