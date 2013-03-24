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
local DeadEnemy   = require("DeadEnemy")

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
  self.requestJump = false
  self.requestMoveX = 0
end

-- fisix
Enemy.GRAVITY    = 700
Enemy.MOVE_X     = 50.0
Enemy.MAX_DX     = 1000.0
Enemy.FRICTION_X = 50

-- combat
Enemy.ATTACK =
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
Resources
--]]

function Enemy:life_change(nb, level)
  local newLife = self.life + nb
  if newLife <= 0 then
    local player = level:getObject(GameObject.TYPE["PLAYER"])
    player:magic_change(player.MAXMANA*0.2)
    
    newLife = 0
    self.purge = true
    local deadEnemy = DeadEnemy(self.x, self.y, 64, 128)
    deadEnemy.dx, deadEnemy.dy = self.dx, self.dy
    level:addObject(deadEnemy)
  end
  self.life = newLife
end

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
    -- knock-back
    push = useful.sign(self:centreX() - other.launcher:centreX())
    self.dx = self.dx + push * other.knockback

    -- lost life
    self:life_change(-other.damage, level)
  
  -- collision with player
  elseif other.type == GameObject.TYPE.PLAYER then
    self.facing = useful.tri(other:centreX() > self:centreX(), 1, -1)
    if self.reloadTime <= 0 then
      level:addObject(self:attack(self.ATTACK, other))
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
  
  -- AI
  local player = level:getObject(GameObject.TYPE.PLAYER)
  
  -- desire jump?
  if player.y + player.h < self.y then
    requestJump = true
  end
  
  -- desire move?
  local player_side = player:centreX() - self:centreX()
  -- ... left
  if player_side < -self.w then
    self.requestMoveX = -1
  end
  -- ... right
  if player_side > self.w then
    self.requestMoveX = 1
  end
  
  -- base update
  Character.update(self, dt, level)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Enemy