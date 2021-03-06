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
local GameObject = require("GameObject")

--[[------------------------------------------------------------
BONUS CLASS
--]]------------------------------------------------------------


local Bonus = Class
{
  init = function(self, x, y, w, h)
    GameObject.init(self, x, y, w, h)
    self.image     = love.graphics.newImage("assets/sprites/bonus.png")
    self.offset    = 0
  end,
      
  type  =  GameObject.TYPE["BONUS"],
}
Bonus:include(GameObject)

function Bonus:draw()
  love.graphics.draw(self.image, self.x, 
      self.y + math.cos(self.offset)*16)

  -- debug
  GameObject.draw(self)
end

function Bonus:update(dt)
  self.offset = self.offset + dt*4
  if self.offset > math.pi*2 then
    self.offset = self.offset - math.pi*2
  end
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Bonus