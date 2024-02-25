--[[
    This is based on https://github.com/games50/pokemon/blob/master/src/states/game/PlayState.lua.
    So I'm copying the header comment verbatim.

    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

require "util"
require "claw"
require "prize"

PlayState = Class{__includes = BaseState}

function PlayState:init()
    i = 1
    for index, file_name in ipairs(image_files) do
        if string.find(file_name, "pirate_", 1)
        then
            local path = "assets/" .. file_name
            pirate_images[i] = love.graphics.newImage(path)
            i = i + 1
        end
    end
    claw = Claw:new({
        x = 0,
        y = 0,
        drawable = hook
    })
end

function PlayState:update(dt)
    initLevel(level)
    -- see https://love2d.org/wiki/KeyConstant
    if love.keyboard.wasPressed("right") and claw and not claw.is_moving_right
    then
        claw.is_moving_right = true
	end
    if love.keyboard.wasPressed("space") and claw and claw.is_moving_right
    then
        claw.is_moving_right = false
        claw.is_capturing = true
	end
    if show_speech_bubble
    then
        timer_speech_bubble = timer_speech_bubble + dt
        if timer_speech_bubble > 5
        then
            show_speech_bubble = false
            show_prizes = true
            timer_speech_bubble = 0
        end
    else
        timer_hints = timer_hints + dt
        if claw and not claw.has_moved_right and not claw.is_capturing and timer_hints > 2
        then
            timer_hints = 0
            hint_opacity = (hint_opacity == 0.5) and 1 or 0.5
        end 
    end
    if claw.is_moving_right
    then
        claw:move_right(1)
    end
    if claw.is_capturing
    then
        local stop_at_y = 64 - claw.drawable:getHeight() / 4
        claw:move_down(1, stop_at_y)
        if claw.y >= stop_at_y
        then
            claw.is_capturing = false
            claw.has_captured = true
            captured_prize_index = claw:check_capture_prize(prize_images)
        end
    elseif claw.has_captured
    then
        if claw.y > 0 or claw.x > 10
        then 
            love.event.push("hasCaptured", -1)
        elseif not end_game
        then
            checkRequestedPrize()
        end
    end
end

function PlayState:render()
    -- Love2D uses 0-1 and not 0-255 (because why fix what isn't broken in other game libraries right?)
    red = 255/255
    green = 255/255
    blue = 255/255
    alpha = 100/100
    local white = { red, green, blue, alpha }
    love.graphics.clear(white)
    love.graphics.setBackgroundColor(white)
    love.graphics.draw(npc, 
        npc_quad, 
        0, 
        love.graphics.getHeight() - 128)
    if show_speech_bubble
    then
        local npc_sw, npc_sh = npc_quad:getTextureDimensions()
        local speech_sw, speech_sh = speech_blank:getTextureDimensions()
        -- https://love2d.org/forums/viewtopic.php?p=193641&sid=b376bddc1cbf02f8f5000259871a79e9#p193641
        love.graphics.draw(speech, 
            speech_blank, 
            16, 
            love.graphics.getHeight() - (128 * 1.1) - speech_sh,
            0,
            1,
            1.5)
        
        love.graphics.draw(prize_images[requested_prize_index].drawable,
            16, 
            love.graphics.getHeight() - (128 * 1.1) - speech_sh)
    end
    if not (level_started or end_game)
    then
        -- https://love2d.org/wiki/love.graphics.push
        love.graphics.push("all")
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.printf("Loading...",
            font,
            love.graphics.getWidth() / 2 - 300, 
            love.graphics.getHeight() / 2, 
            600,
            "center")
        love.graphics.pop()
    else
        if show_prizes
        then
            love.graphics.draw(claw.drawable, claw.x, claw.y)
            for i, prize in ipairs(prize_images) do
                love.graphics.draw(prize.drawable, prize.x, prize.y)
            end
            if claw and not claw.is_capturing and not claw.has_captured
            then
                local hint_text = (not claw.is_moving_right) and "Press →" or "Press Space"
                -- This API makes no sense. Why not just have a drawing function that accepts a color :(
                love.graphics.push("all")
                love.graphics.setColor(0, 0, 0, hint_opacity)
                love.graphics.printf(hint_text,
                    font,
                    love.graphics.getWidth() / 2 - 100, 
                    love.graphics.getHeight() / 2, 
                    200,
                    "center")
                love.graphics.pop()
            end
        end
        if end_game
        then
            love.graphics.push("all")
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.printf("Game Over! Thanks for playing",
                font,
                love.graphics.getWidth() / 2 - 300, 
                love.graphics.getHeight() / 2, 
                600,
                "center")
            love.graphics.pop()
        end
    end
    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.line(129, 0, 129, love.graphics.getHeight())
    love.graphics.printf("Level: " .. level,
        font_small,
        0, 
        love.graphics.getHeight() - (font_small:getHeight() * 1.1), 
        love.graphics.getWidth(),
        "right")
    love.graphics.pop()
end

function love.handlers.hasCaptured(step)
    local prize = prize_images[captured_prize_index]
    claw:move_return(step)
    if prize -- it's possible for the claw to not catch anything
    then
        local dimension = (claw.y > 0) and "y" or "x"
        prize:move_return(step, dimension)
    end
end

function checkRequestedPrize()
    win_level = (requested_prize_index == captured_prize_index)
    npc_quad = win_level and npc_smile or npc_sad
    show_speech_bubble = true

    if level < 3
    then
        end_game = not win_level
        level_started = false
    else
        end_game = true
    end
end

function initLevel()
    if not level_started and not end_game
    then
        level = level + 1
        end_game = false
        win_level = false
        captured_prize_index = 0
        claw.has_captured = false
        love.timer.sleep(3)
        npc_quad = npc_ask
        show_speech_bubble = false

        -- randomize the prizes
        local prize_count = 4 + level
        local shuffled_images = shuffle(pirate_images)
        while #shuffled_images > prize_count do
            table.remove(shuffled_images)
        end
        -- set the correct prize
        requested_prize_index = math.random(1, prize_count)
        for i = 1, prize_count do 
            prize_images[i] = Prize:new({
                display_index = i,
                drawable = shuffled_images[i],
                x = 64 * ((i - 1) * 2) + 128, 
                y = 64
            })
        end
        level_started = true
        show_speech_bubble = true
    end
end
