--[[
(C) Copyright 2013 
William Dyce, Maxime Ailloud, Alex Verbrugghe, Julien Deville

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

local useful = require("useful")


--[[------------------------------------------------------------
CONSTANTS
--]]------------------------------------------------------------

local _BACKGROUND_IMG = nil
local _BACKGROUND_IMG_W = nil
local _BACKGROUND_IMG_H = nil

local _PROLOGUE1_IMG = nil
local _PROLOGUE1_IMG_W = nil
local _PROLOGUE1_IMG_H = nil


local _PROLOGUE2_IMG = nil
local _PROLOGUE2_IMG_W = nil
local _PROLOGUE2_IMG_H = nil

--[[------------------------------------------------------------
GAME GAMESTATE
--]]------------------------------------------------------------

local _page_turned = false

local state = GameState.new()

function state:init()
	_BACKGROUND_IMG = love.graphics.newImage("assets/menu/prologue_bg.jpg")
	_BACKGROUND_IMG_W = _BACKGROUND_IMG:getWidth()
	_BACKGROUND_IMG_H = _BACKGROUND_IMG:getHeight()

	_PROLOGUE1_IMG = love.graphics.newImage("assets/menu/prologue_1.png")
	_PROLOGUE1_IMG_W = _PROLOGUE1_IMG:getWidth()
	_PROLOGUE1_IMG_H = _PROLOGUE1_IMG:getHeight()

	_PROLOGUE2_IMG = love.graphics.newImage("assets/menu/prologue_2.png")
	_PROLOGUE2_IMG_W = _PROLOGUE2_IMG:getWidth()
	_PROLOGUE2_IMG_H = _PROLOGUE2_IMG:getHeight()
end

function state:enter()
	_page_turned = false
end


function state:leave()
end

function state:keypressed(key, uni)
  -- exit
  if key=="escape" then
    GameState.switch(title)
  else
  	if _page_turned then
  		GameState.switch(game)
  	else
  		_page_turned = true
  	end
 	end
end

function state:keyreleased(key, uni)
end


function state:joystickpressed( joystick, button )
	if _page_turned then
		GameState.switch(game)
	else
		_page_turned = true
	end
end

function state:joystickreleased( joystick, button )
end

local _t = 0

function state:update(dt)
	_t = _t + 0.5*dt
	if _t > 1 then
		_t = _t - 1
	end
end


function state:draw()

	local offset = math.cos(_t*math.pi*2)

  -- draw background
  scaled_draw(_BACKGROUND_IMG,
  	DEFAULT_W*0.5 - _BACKGROUND_IMG_W*0.5, 
  	DEFAULT_H*0.5 - _BACKGROUND_IMG_H*0.5,
  	0, SCALE_MAX, SCALE_MAX)

  -- prologue text
  if _page_turned then
	  scaled_draw(_PROLOGUE2_IMG,
	  	DEFAULT_W*0.5 - _PROLOGUE2_IMG_W*0.5, 
	  	DEFAULT_H*0.5 - _PROLOGUE2_IMG_H*0.5 + 48 + 8*offset)
	else
	  scaled_draw(_PROLOGUE1_IMG,
	  	DEFAULT_W*0.5 - _PROLOGUE1_IMG_W*0.5, 
	  	DEFAULT_H*0.5 - _PROLOGUE1_IMG_H*0.5 + 48 + 8*offset)
	end
end

return state