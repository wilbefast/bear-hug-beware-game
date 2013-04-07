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

local Character   = require("Character")
local GameObject  = require("GameObject")
local Attack      = require("Attack")
local Class       = require("hump/class")
local useful      = require("useful")
local Animation   = require("Animation")

--[[------------------------------------------------------------
ENEMY CLASS
--]]------------------------------------------------------------

local SPRITE_SHEET = love.graphics.newImage("assets/sprites/enemy.png")

local ANIM_STAND = Animation(SPRITE_SHEET, 128, 128, 6, 0, 0)
local ANIM_PAIN = Animation(SPRITE_SHEET, 128, 128, 1, 768, 0)
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
  Character.init(self, x, y, w, h, 
      ANIM_STAND, ANIM_STAND, ANIM_STAND, ANIM_PAIN)
end

-- fisix
Enemy.GRAVITY    = 1200
Enemy.BOOST      = 700
Enemy.MOVE_X     = 3000.0
Enemy.MAX_DX     = 3000.0
Enemy.FRICTION_X = 50

-- combat
Enemy.ATTACK =
{
  REACH = 32,
  OFFSET_Y = 74,
  OFFSET_X = 0,
  DAMAGE = 10,
  MANA = 0,
  WARMUP_TIME = 0.4,
  RELOAD_TIME = 0.3,
  STUN_TIME = 0.5,
  W = 118,
  H = 108,
  KNOCKBACK = 300,
  reloadTime = 0
}

-- ai
Enemy.PERCENT_JUMPING = 0.1


--[[------------------------------------------------------------
Collisions
--]]

function Enemy:collidesType(type)
  return ((type == GameObject.TYPE.PLAYER)
      or (type == GameObject.TYPE.ATTACK)
      or (type == GameObject.TYPE.DEATH)
      or (type == GameObject.TYPE.ENEMY))
end

function Enemy:eventCollision(other, level)
  -- collision with attack
  if other.type == GameObject.TYPE.ATTACK then
    -- knock-back and -up
    push = useful.sign(self:centreX() - other.launcher:centreX())
    self.dx = self.dx + push * other.weapon.KNOCKBACK
    self.dy = self.dy - other.weapon.KNOCKUP
    -- set stunned
    self:setState(Character.STATE.STUNNED)
    self.timer = other.weapon.STUN_TIME
    -- lose life
    self:addLife(-other.weapon.DAMAGE, level)
  
  -- collision with death
  elseif other.type == GameObject.TYPE.DEATH then
    self:addLife(-math.huge)
  
  -- collision with other characters
  elseif other.type == GameObject.TYPE.ENEMY 
  or other.type == GameObject.TYPE.PLAYER then
    if (self.state ~= self.STATE.STUNNED)
    and (other.state ~= other.STATE.STUNNED) then
      push = (self:centreX() - other:centreX())
      self.dx = self.dx + push * 3
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

  -- AI
  local player = level:getObject(GameObject.TYPE.PLAYER)
  local ecart = player:centreX() - self:centreX()
    -- desire move?
  if math.abs( ecart ) < 800 and math.abs( ecart ) > 30 then
    -- ... left
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
  
  -- desire jump?
  local delta_y = self.y - player.y
  if delta_y > 0 then
    if (delta_y > player.h*2) 
    or ((delta_y / player.h / 2 * self.PERCENT_JUMPING) > math.random() ) then
      self.requestJump = true
    end
  end

  -- base update
  Character.update(self, dt, level)
end



function Enemy:draw()
  Character.draw(self)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Enemy