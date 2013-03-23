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

local Character = require("character")
local GameObject = require("GameObject")
local Class     = require("hump/class")

--[[------------------------------------------------------------
ENEMY CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialise
--]]
local Enemy = Class
{
  type  =  GameObject.TYPE["ENEMY"],
}
Enemy:include(Character)

function Enemy:init(x, y)
  -- base constructor
  Character.init(self, x, y, "assets/sprites/sol.png")
end

Enemy.GRAVITY         = 30
Enemy.ATTACK_INTERVAL = 2
Enemy.DAMAGE          = 6

Enemy.w = 128
Enemy.h = 128

--[[------------------------------------------------------------
Collisions
--]]

function Enemy:collidesType(type)
  return (type == GameObject.TYPE.PLAYER)
end

function Enemy:eventCollision(other)
  if self.reloadTime <= 0 then
    other:life_change(-self.DAMAGE)
    self.reloadTime = self.ATTACK_INTERVAL
  end
end

--[[------------------------------------------------------------
Game loop
--]]

function Enemy:update(dt, level)
  -- base update
  Character.update(self, dt, level)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Enemy