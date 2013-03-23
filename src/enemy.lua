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
local Attack      = require("Attack")
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
  self.requestLightAttack = true
end

-- fisix
Enemy.GRAVITY         = 700
Enemy.MOVE_X         = 50.0
Enemy.MAX_DX         = 1000.0
Enemy.FRICTION_X = 50

-- combat - light attack
Enemy.LIGHTATTACK =
{
  REACH = 80,
  OFFSET_Y = 32,
  DAMAGE = 6,
  RELOAD_TIME = 2,
  W = 40,
  H = 40,
  KNOCKBACK = 300
}

--[[------------------------------------------------------------
Collisions
--]]

function Enemy:collidesType(type)
  return ((type == GameObject.TYPE.PLAYER)
      or (type == GameObject.TYPE.ATTACK))
end

function Enemy:eventCollision(other, level)
  -- collision with attack
  if other.type == GameObject.TYPE.ATTACK then
    self:life_change(-other.damage)
    -- knock-back
    push = useful.sign(self:centreX() - other.launcher:centreX())
    self.dx = self.dx + push * other.knockback
  
  -- collision with player
  elseif other.type == GameObject.TYPE.PLAYER then
    self.facing = useful.tri(other:centreX() > self:centreX(), 1, -1)
    if self.requestLightAttack then
      if self.reloadTime <= 0 then
        level:addObject(self:attack(self.LIGHTATTACK, other))
      end
    end
  end
end

--[[------------------------------------------------------------
Combat
--]]

function Enemy:attack(attack, target)
  self.reloadTime = attack.RELOAD_TIME
  local target_distance = math.abs(target.x - self.x)
  local reach = math.min(attack.REACH, target_distance)
  
  local newAttack = Attack(
    self.x + self.w/2 + reach*self.facing,
    self.y + attack.OFFSET_Y,
    attack.W,
    attack.H,
    attack.DAMAGE,
    self,
    attack.KNOCKBACK)
  newAttack.type = GameObject.TYPE.ENEMYATTACK
  return newAttack
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