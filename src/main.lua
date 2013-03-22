--[[
(C) Copyright 2013 
William Dyce, Maxime Ailloud, Alex Averbrugghe, Julien Deville

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
  gstate = require("hump/gamestate")
  title = require("title")
  gstate.switch(title)
end


function love.focus(f)
  gstate.focus(f)
end

function love.mousepressed(x, y, btn)
  gstate.mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
  gstate.mousereleased(x, y, btn)
end

function love.joystickpressed(joystick, button)
  gstate.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
  gstate.joystickreleased(joystick, button)
end

function love.quit()
  gstate.quit()
end

function love.keypressed(key, uni)
  gstate.keypressed(key, uni)
end

function keyreleased(key, uni)
  gstate.keyreleased(key)
end

MAX_DT = 1/30 -- global!
function love.update(dt)
  dt = math.min(MAX_DT, dt)
  gstate.update(dt)
end

function love.draw()
  gstate.draw()
  love.graphics.print(love.timer.getFPS(), 10, 10)
end
