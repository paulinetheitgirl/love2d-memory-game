--[[
    This is based on https://github.com/games50/pokemon/blob/master/src/states/game/StartMenuState.lua
    So I'm copying the header comment verbatim.
    
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

require "claw"

StartMenuState = Class{__includes = BaseState}

function StartMenuState:init()
    self.claw_animation = Claw:new({
        x = -10,
        y = 0,
        drawable = hook,
        is_moving_right = true
    })
end

function StartMenuState:update(dt)
    if self.claw_animation.is_moving_right
    then
        self.claw_animation:move_right(1, true)
    end
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateStack:push(PlayState(), 
        1,
        function()
            gStateStack:pop()
        end)
    end
end

function StartMenuState:render()
    love.graphics.clear(51/255, 179/255, 255/255, 1)

    love.graphics.draw(self.claw_animation.drawable, self.claw_animation.x, self.claw_animation.y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Memory Catch-arrr!",
            font,
            love.graphics.getWidth() / 2 - 300, 
            love.graphics.getHeight() / 2  - (font:getHeight() * 2), 
            600,
            "center")
    love.graphics.printf("Press ˿⌋",
            font_small,
            love.graphics.getWidth() / 2 - 300, 
            love.graphics.getHeight() / 2 - font:getHeight(), 
            600,
            "center")
end