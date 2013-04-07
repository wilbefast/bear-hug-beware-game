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

local Class      = require("hump/class")
local GameObject = require("GameObject")
local useful     = require("useful")

--[[------------------------------------------------------------
GIBLET CLASS
--]]------------------------------------------------------------

local BLOOD_DROP = 
  love.graphics.newImage("assets/sprites/blood_drop.png")
local BLOOD_SPLAT = 
  love.graphics.newImage("assets/sprites/blood_splat.png")

  
local Giblet = Class
{
  init = function(self, x, y, dx, dy)
    x, y = x + math.random()*32, y + math.random()*32
    GameObject.init(self, x, y, 0, 16)
    self.dx = dx + math.random()*700 - 350
    self.dy = dy - math.random()*300 - 300
    self.view = GameObject.DEBUG_VIEW
  end,
      
  type  =  GameObject.TYPE["GIBLET"],
}
Giblet:include(GameObject)

Giblet.spawn = function (level, x, y, number, dx, dy)
  for i = 1, number do
    level:addObject(Giblet(x, y, dx, dy))
  end
end

-- fisix
Giblet.GRAVITY    = 1000
Giblet.FRICTION_X = 10


--[[------------------------------------------------------------
Game loop
--]]

function Giblet:update(dt, level, view)
  -- base update
  GameObject.update(self, dt, level, view)
  
  -- stop and destroy
  if not self.airborne then
    if (self.dx ~= 0) or (self.dy ~= 0) then
      self.dx, self.dy = 0, 0
    end
    if not self:isColliding(view) then
      self.purge = true
    end
  end
end

function Giblet:draw()
  
  local img = 
    useful.tri(self.airborne, BLOOD_DROP, BLOOD_SPLAT)
  love.graphics.draw(img, 
      self:centreX() - img:getWidth()/2, self.y + 8)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Giblet