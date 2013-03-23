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
local Class     = require("hump/class")

--[[------------------------------------------------------------
ENEMY CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialise
--]]
local Enemy = Class
{
  type  = "enemy",
}
Enemy:include(Character)

function Enemy:init(x, y)
  -- base constructor
  Character.init(self, x, y, "assets/sprites/sol.png")
end

Enemy.GRAVITY = 30

Enemy.w = 64
Enemy.h = 64

--[[------------------------------------------------------------
Collisions
--]]

function Enemy:eventCollision(other)
  -- TODO
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