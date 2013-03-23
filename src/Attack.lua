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
  init = function(self, x, y, damage, w, h)
    GameObject.init(self, x, y)
    self.damage = damage
    self.w = w
    self.h = h
  end,
      
  type  = "attack",
}
Attack:include(GameObject)


--[[------------------------------------------------------------
Game loop
--]]

function Attack:update(dt, tilegrid)
  -- destroy self
  self.purge = true
end

function Attack:draw(view)
  -- FIXME debug
  GameObject.draw(self)
end

return Attack