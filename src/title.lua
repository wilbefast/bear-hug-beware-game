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

local TITLE_IMG = nil
local TITLE_IMG_W = nil
local TITLE_IMG_H = nil

--[[------------------------------------------------------------
GAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
	TITLE_IMG = love.graphics.newImage("assets/menu/title.png")
	TITLE_IMG_W = TITLE_IMG:getWidth()
	TITLE_IMG_H = TITLE_IMG:getHeight()
end

function state:enter()
end


function state:leave()
end

function state:keypressed(key, uni)
  -- exit
  if key=="escape" then
    love.event.push("quit")
  else
  	GameState.switch(prologue)
 	end
end

function state:keyreleased(key, uni)
end


function state:joystickpressed( joystick, button )
	GameState.switch(prologue)
end

function state:joystickreleased( joystick, button )
end

local _t = 0

function state:update(dt)
	_t = _t + 0.3*dt
	if _t > 1 then
		_t = _t - 1
	end
end


function state:draw()

	local offset = math.cos(_t*math.pi*2)

	  -- draw the sky
	  love.graphics.draw(SKY, 0, 0, 0, SCALE_MIN, SCALE_MIN)

	  -- draw the horizon mountains
	  local y_horizon = -4*(1 + offset)
	  scaled_drawq(HORIZON, QHORIZON, 0, y_horizon)
	  love.graphics.setColor(160, 61, 96)
	    scaled_rect("fill", 
	    	0, HORIZON_H + y_horizon, DEFAULT_W, DEFAULT_H - HORIZON_H)
	  love.graphics.setColor(255, 255, 255)
	    
	  -- draw the background mountains
	  local y_mountains = -8*(1 - offset) - 64
	  scaled_drawq(MOUNTAINS, QMOUNTAINS, 0, y_mountains)

	  love.graphics.setColor(104, 161, 127)
	    scaled_rect("fill", 
	    	0, y_mountains + MOUNTAINS_H, DEFAULT_W, DEFAULT_H)
	  love.graphics.setColor(255, 255, 255)

	  -- title
	  scaled_draw(TITLE_IMG, 
	  	(DEFAULT_W - TITLE_IMG_W)*0.5, 
	  	(DEFAULT_H - TITLE_IMG_H)*0.5)

end

return state