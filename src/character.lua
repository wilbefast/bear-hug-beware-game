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

local Class = require("hump/class")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Character = Class{
  init = function(self, position, image)
    self.position = position
    self.image    = image
  end,
  speed = 5,
  type  = "character"
}

function Character:update(dt)
  -- see hump.vector
  local delta = vector(0,0)
    if love.keyboard.isDown('left') then
      delta.x = -1
    elseif love.keyboard.isDown('right') then
      delta.x =  1
    end
    if love.keyboard.isDown('up') then
      delta.y = -1
    elseif love.keyboard.isDown('down') then
      delta.y =  1
    end
    delta:normalize_inplace()

    player.velocity = Character.velocity + delta * Character.acceleration * dt

    if Character.velocity:len() > Character.max_velocity then
      player.velocity = Character.velocity:normalized() * Character.max_velocity
    end

    player.position = Character.position + Character.velocity * dt
end

function Character:draw()
  image = love.graphics.newImage(self.image)
  love.graphics.draw(image, 50, 50)
end

return Character