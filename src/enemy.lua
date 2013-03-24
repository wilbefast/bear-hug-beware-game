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

  self.stunned = false
  fic="assets/audio/cri_mort.ogg"
  cri_mort = love.audio.newSource(fic,"static")

end

-- fisix
Enemy.GRAVITY    = 1200
Enemy.BOOST    = 700
Enemy.MOVE_X     = 30.0
Enemy.MAX_DX     = 500.0
Enemy.FRICTION_X = 50

-- combat
Enemy.ATTACK =
{
  REACH = 32,
  OFFSET_Y = 74,
  OFFSET_X = 0,
  DAMAGE = 10,
  MANA = 0,
  RELOAD_TIME = 1,
  STUN_TIME = 0.5,
  W = 118,
  H = 108,
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
	cri_mort:play()
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
    -- knock-back and -up
    push = useful.sign(self:centreX() - other.launcher:centreX())
    self.dx = self.dx + push * other.weapon.KNOCKBACK
    self.dy = self.dy - other.weapon.KNOCKUP

    self.stunnedTime = other.weapon.STUN_TIME
    
    -- lost life
    self:life_change(-other.weapon.DAMAGE, level)
  
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
    self.x + self.w/2 + reach*self.facing + attack.OFFSET_X,
    self.y + attack.OFFSET_Y,
    attack,
    self)
  newAttack.type = GameObject.TYPE.ENEMYATTACK
  return newAttack
end

--[[------------------------------------------------------------
Game loop
--]]

function Enemy:update(dt, level)

  
  if( self.stunnedTime <= 0 ) then
    -- AI
    local player = level:getObject(GameObject.TYPE.PLAYER)
    local ecart = player:centreX() - self:centreX()
      -- desire move?
    if math.abs( ecart ) < 800 and math.abs( ecart ) > 30 then
      -- ... left

      -- desire jump?
      if math.abs( player.y - self.y ) > 63 then
        self.requestJump = true
      end

      if ecart < 1 then
        self.requestMoveX = -1
      end
      -- ... right
      if ecart > 1 then
        self.requestMoveX = 1
      end
    else
      self.requestMoveX = 0
    end


    local moveDir = useful.sign(self.requestMoveX)
    if moveDir ~= 0 then
      self.dx = self.dx + moveDir*self.MOVE_X
      self.facing = moveDir
    end

    -- jump
    if self.requestJump then
      -- check if on the ground
      if (not self.airborne) then
        self.dy = -Enemy.BOOST
        saut:play()
      end
    end

    self.requestJump = false

  end
  
  -- base update
  Character.update(self, dt, level)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Enemy