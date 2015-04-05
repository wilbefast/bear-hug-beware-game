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

--[[------------------------------------------------------------
GAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
end

function state:enter()
end


function state:leave()
end

function state:keypressed(key, uni)
  -- exit
  if key=="escape" then
    GameState.switch(title)
  else
  	GameState.switch(game)
 	end
end

function state:keyreleased(key, uni)
end


function state:joystickpressed( joystick, button )
	GameState.switch(game)
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

local _text = function(t, x, y, line, outline)
  love.graphics.setFont(line)
  love.graphics.setColor(32, 16, 32)
  love.graphics.printf(t, x - 400, y - 4, 800, "center")
	love.graphics.setColor(241, 107, 123)
	love.graphics.setFont(outline)
  love.graphics.printf(t, x - 400, y, 800, "center")
	love.graphics.setColor(255, 255, 255)
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

	  -- credits
	  _text("Credits", WINDOW_W*0.5, -WINDOW_H*0.1, FONT_HUGE, FONT_HUGE_OUTLINE)

	  _text("Maxime Ailloud", WINDOW_W*0.3, WINDOW_H*0.1, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
	  _text("Julien Deville", WINDOW_W*0.3, WINDOW_H*0.3, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
	  _text("William Dyce", WINDOW_W*0.3, WINDOW_H*0.5, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
	  _text("Alex Verbrugghe", WINDOW_W*0.3, WINDOW_H*0.7, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)

	  _text("Jules Bacon", WINDOW_W*0.7, WINDOW_H*0.2, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
	  _text("Stephanie Bottex", WINDOW_W*0.7, WINDOW_H*0.4, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
	  _text("Gaelle Rouby", WINDOW_W*0.7, WINDOW_H*0.6, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
	  _text("Caroline Vic", WINDOW_W*0.7, WINDOW_H*0.8, 
	  	FONT_LARGE, FONT_LARGE_OUTLINE)
end

return state