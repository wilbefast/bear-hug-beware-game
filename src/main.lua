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


function love.load(arg)
  GameState = require("hump/gamestate")
  conf = require("conf")
  title = require("title")
  game = require("game")
  histoire = require("histoire")
  GameState.switch(title)

  love.mouse.setVisible( false )
  
end


function love.focus(f)
  GameState.focus(f)
end

function love.mousepressed(x, y, btn)
  GameState.mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
  GameState.mousereleased(x, y, btn)
end

function love.joystickpressed(joystick, button)
  GameState.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
  GameState.joystickreleased(joystick, button)
end

function love.quit()
  GameState.quit()
end

function love.keypressed(key, uni)
  GameState.keypressed(key, uni)
end

function keyreleased(key, uni)
  GameState.keyreleased(key)
end

MAX_DT = 1/30 -- global!
function love.update(dt)
  dt = math.min(MAX_DT, dt)
  GameState.update(dt)
end

function love.draw()
  GameState.draw()
  love.graphics.print(love.timer.getFPS(), 10, 10)
end
