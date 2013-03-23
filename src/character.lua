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
  init = function(self, x, y, image)
    self.x        = x
    self.y        = y
    self.image    = image
    self.dx       = 0
    self.dy       = 0
  end,
  life  = 100,
  speed = 5,
  type  = "character"
}

function Character:update(dt)
  -- move based on speed
  self.x = self.x + self.dx
  self.y = self.y + self.dy
end

function Character:draw(view)
  image = love.graphics.newImage(self.image)
  love.graphics.draw(image, self.x, self.y)
end

return Character