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
CHARACTER CLASS
--]]------------------------------------------------------------


local Attack = Class
{
  init = function(self, x, y, weapon, launcher, directional)
    GameObject.init(self, x-weapon.W/2, y-weapon.H/2, 
                    weapon.W, weapon.H)
    self.weapon = (weapon or self)
    self.launcher = (launcher or self)
    self.timer = 0 --FIXME (weapon.DURATION or 0)
  end,
      
  type  =  GameObject.TYPE["ATTACK"],
}
Attack:include(GameObject)


--[[------------------------------------------------------------
Game loop
--]]

function Attack:update(dt, level)
  -- destroy self on *second* update
  if self.timer < 0 then
    self.purge = true
  else
    self.timer = self.timer - dt
  end
end

function Attack:draw()
  -- debug
  GameObject.draw(self)
end

return Attack