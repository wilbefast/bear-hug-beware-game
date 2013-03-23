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

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

local Level = require("Level")
local Camera = require("hump/camera")

--[[------------------------------------------------------------
LEVEL CLASS
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
  -- create objects
  self.level = Level()
  self.camera = Camera(0, 0)
end


function state:enter()
  -- reset objects
  self.level:load("../assets/maps/map01")
  self.camera:lookAt(128, 128) --FIXME look at player
end


function state:focus()
end


function state:mousepressed(x, y, btn)

end


function state:mousereleased(x, y, btn)
  
end


function state:joystickpressed(joystick, button)
  
end


function state:joystickreleased(joystick, button)
  
end


function state:quit()
  
end


function state:keypressed(key, uni)
  if key=="escape" then
    GameState.switch(title)
  end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  --FIXME 
  if love.keyboard.isDown("left") then
    self.camera.x = self.camera.x - dt*512
  end
  if love.keyboard.isDown("right") then
    self.camera.x = self.camera.x + dt*512
  end
  if love.keyboard.isDown("down") then
    self.camera.y = self.camera.y + dt*512
  end
  if love.keyboard.isDown("up") then
    self.camera.y = self.camera.y - dt*512
  end
end


function state:draw()
  love.graphics.print("Game screen", 32, 32)
  
  self.camera:attach()
  self.level:draw()
  self.camera:detach()
end

return state