--[[
    This is based on https://github.com/games50/pokemon/blob/master/main.lua

    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

require "util"
require "claw"
require "prize"

Class = require "class"
require "base_state"
require "state_stack"
push = require "push"
require "states_play"
require "states_menu"

VIRTUAL_WIDTH = 960
VIRTUAL_HEIGHT = 300
TILE_SIZE = 16

show_speech_bubble = false
timer_speech_bubble = 0
timer_hints = 0
hint_opacity = 0.5
level_started = false
end_game = false
level = 0
prize_images = {}
show_prizes = false
requested_prize_index = 0
captured_prize_index = 0
-- https://fonts.google.com/noto/specimen/Noto+Sans+Mono/about
font = love.graphics.newFont("assets/NotoSansMono-VariableFontt.ttf", 48)
font_small = love.graphics.newFont("assets/NotoSansMono-VariableFontt.ttf", 24)
hook = love.graphics.newImage("assets/hook.png")
npc_quad = {}
npc = love.graphics.newImage("assets/portraits_pack.png")
npc_ask = love.graphics.newQuad(128, 0, 128, 128, npc)
npc_quad = npc_ask
npc_smile = love.graphics.newQuad(0, 0, 128, 128, npc)
npc_sad = love.graphics.newQuad(512, 0, 128, 128, npc)
speech = love.graphics.newImage("assets/speech_bubble.png")
speech_blank = love.graphics.newQuad(0, 0, 64, 64, speech)
image_files = love.filesystem.getDirectoryItems("assets")
pirate_images = {}

function love.load()
    WINDOW_WIDTH = love.graphics.getWidth()
    WINDOW_HEIGHT = love.graphics.getHeight()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    window_width,window_height = love.graphics.getDimensions()
	window_scale_y = window_height/WINDOW_HEIGHT
	window_scale_x = window_scale_y
	window_translate_x = (window_width - (window_scale_x * WINDOW_WIDTH))/2
    push:setupScreen(window_scale_x, window_scale_y, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- this time, we are using a stack for all of our states, where the field state is the
    -- foundational state; it will have its behavior preserved between state changes because
    -- it is essentially being placed "behind" other running states as needed (like the battle
    -- state)

    gStateStack = StateStack()
    gStateStack:push(StartMenuState())

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    gStateStack:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    gStateStack:render()
    push:finish()
end