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


local Character = Class
{
  init = function(self, x, y, w, h, imagefile)
    GameObject.init(self, x, y, w, h)
    self.image    = love.graphics.newImage(imagefile)
  end,

  life       = 100,
  magic      = 100,
  damage     = 0,
  reloadTime = 0,
}
Character:include(GameObject)


--[[------------------------------------------------------------
Resources
--]]

--function Charactr


--[[------------------------------------------------------------
Resources
--]]

function Character:life_change(nb)
  local newLife = self.life + nb
  if newLife < 0 then
    newLife = 0
  end
  self.life = newLife
end

function Character:magic_change(nb)
  local newMagic = self.magic + nb
  if newMagic < 0 then
    newMagic = 0
  end
  self.magic = newMagic
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, level)
  -- update reloadTime for attack
  if self.reloadTime > 0 then
    self.reloadTime = self.reloadTime - dt
  end
  
  -- base update
  GameObject.update(self, dt, level)
end

function Character:draw()
  -- FIXME animation
  love.graphics.draw(self.image, self.x, self.y)
  -- FIXME debug
  GameObject.draw(self)
end

return Character