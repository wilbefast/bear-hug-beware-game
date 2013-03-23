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

local Character   = require("character")
local GameObject  = require("GameObject")
local Class       = require("hump/class")
local useful      = require("useful")

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

function Enemy:init(x, y, w, h)
  -- base constructor
  Character.init(self, x, y, w, h, "assets/sprites/sol.png")
end

-- fisix
Enemy.GRAVITY         = 700
Enemy.MOVE_X         = 50.0
Enemy.MAX_DX         = 1000.0
Enemy.FRICTION_X = 50
-- combat
Enemy.ATTACK_INTERVAL = 2
Enemy.DAMAGE          = 6

--[[------------------------------------------------------------
Collisions
--]]

function Enemy:collidesType(type)
  return ((type == GameObject.TYPE.PLAYER) 
      or (type == GameObject.TYPE.ATTACK))
end

function Enemy:eventCollision(other)
  -- collision with attack
  if other.type == GameObject.TYPE.ATTACK then
    self:life_change(-other.damage)
    -- knock-back
    push = useful.sign(self.x - other.launcher:centreX())
    self.dx = self.dx + push * other.knockback
  
  -- collision with player
  elseif other.type == GameObject.TYPE.PLAYER then
    if self.reloadTime <= 0 then
      other:life_change(-self.DAMAGE)
      self.reloadTime = self.ATTACK_INTERVAL
    end
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