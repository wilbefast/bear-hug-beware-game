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

local Class       = require("hump/class")
local Character   = require("Character")
local GameObject  = require("GameObject")
local Attack      = require("Attack")
local useful      = require("useful")
local Animation   = require("Animation")
local AnimationView = require("AnimationView")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------

local SPRITE_SHEET = love.graphics.newImage("assets/sprites/hero.png")
local ANIM_WALK = Animation(SPRITE_SHEET, 128, 128, 8)
local ANIM_STAND = Animation(SPRITE_SHEET, 128, 128, 8, 0, 128)
local ANIM_JUMP = Animation(SPRITE_SHEET, 128, 128, 3, 0, 256)
local ANIM_MAGIC = Animation(SPRITE_SHEET, 128, 128, 2, 768, 256)
local ANIM_BUTT = Animation(SPRITE_SHEET, 128, 128, 3, 0, 384)
local ANIM_PAIN = Animation(SPRITE_SHEET, 128, 128, 1, 384, 384)
local ANIM_DEAD = Animation(SPRITE_SHEET, 128, 128, 1, 512, 384)

--[[------------------------------------------------------------
Initialise
--]]

local Player = Class
{
  type  =  GameObject.TYPE["PLAYER"],

  -- constructor
  init = function(self, x, y)
  
    ---- Character
    Character.init(self, x, y, 64, 128,
        ANIM_STAND, ANIM_WALK, ANIM_JUMP, ANIM_PAIN)
  end,
}
Player:include(Character)

--[[------------------------------------------------------------
Constants
--]]

-- physics
Player.MOVE_X = 3000.0
Player.MAX_DX = 1000.0
Player.BOOST = 1000.0
Player.GRAVITY = 1500.0
Player.FRICTION_X = 50

-- combat - light attack
Player.LIGHTATTACK = 
{
  REACH = 32,
  OFFSET_Y = 74,
  OFFSET_X = 0,
  DAMAGE = 35,
  MANA = 0,
  WARMUP_TIME = 0.2,
  DURATION = 0.1,
  RELOAD_TIME = 0.04,
  STUN_TIME = 0.5,
  W = 118,
  H = 108,
  KNOCKBACK = 1000,
  KNOCKUP = 150,
  ANIM_WARMUP = ANIM_BUTT,

  reloadTime = 0
}
-- combat - magic attack
Player.MAGICATTACK = 
{
  REACH = 0,
  OFFSET_Y = 64,
  OFFSET_X = -32,
  DAMAGE = 20,
  MANA = 10,
  WARMUP_TIME = 0.4,
  DURATION = 0.2,
  RELOAD_TIME = 0.3,
  STUN_TIME = 1,
  W = 256,
  H = 256,
  KNOCKBACK = 2000,
  KNOCKUP = 300,
  ANIM_WARMUP = ANIM_MAGIC,
  
  reloadTime = 0
}

Player.MAXMANA = 100

--[[------------------------------------------------------------
Collisions
--]]

function Player:collidesType(type)
  return ((type == GameObject.TYPE.ENEMY)
      or (type == GameObject.TYPE.ENEMYATTACK)
      or (type == GameObject.TYPE.DEATH)
      or (type == GameObject.TYPE.BONUS))
end

function Player:eventCollision(other)
  -- collision with enemy attack
  if other.type == GameObject.TYPE.ENEMYATTACK then
    self:addLife(-other.weapon.DAMAGE)
    self.baffed = true
    -- knock-back
    push = useful.sign(self:centreX() - other.launcher:centreX())
    self.dx = self.dx + push * other.weapon.KNOCKBACK
  
  -- collision with "death" (bottomless pit)
  elseif other.type == GameObject.TYPE.DEATH then
    self:addLife(-math.huge)

  -- collision with "bonus" 
  elseif other.type == GameObject.TYPE.BONUS then
    self.life = 90
	self.magic = self.MAXMANA
    other.purge = true --! FIXME
  end
end


--[[------------------------------------------------------------
Animations
--]]

function Player:onStateChange(new_state)
  -- TODO
end


--[[------------------------------------------------------------
Game loop
--]]

function Player:update(dt, level)

  -- attack
  if self.state == Character.STATE.NORMAL then
    -- attack
    local weapon = nil
    
    -- ... light
    if self.requestLightAttack then
      weapon = self.LIGHTATTACK
    end
    -- ... magic
    if self.requestMagicAttack then
      if (self.magic >= self.MAGICATTACK.MANA) then
        weapon = self.MAGICATTACK
      end
    end

    if weapon and (weapon.reloadTime <= 0) then
      self:startAttack(weapon)
    end
  end
        
  -- reload weapons
  function reload(weapon, dt)
    weapon.reloadTime = math.max(0, weapon.reloadTime - dt)
  end
  reload(self.LIGHTATTACK, dt)
  reload(self.MAGICATTACK, dt)
  
  -- reset input
  self.requestLightAttack = false
  self.requestMagicAttack = false
  
  -- base update
  Character.update(self, dt, level)
end

function Player:draw()
  Character.draw(self)
end

return Player