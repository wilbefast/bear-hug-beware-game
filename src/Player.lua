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
local audio      = require("audio")
local Animation   = require("Animation")
local AnimationView = require("AnimationView")

--[[------------------------------------------------------------
PLAYER CLASS
--]]------------------------------------------------------------

local SPRITE_SHEET = love.graphics.newImage("assets/sprites/hero.png")
local ANIM_WALK = Animation(SPRITE_SHEET, 128, 128, 8)
local ANIM_STAND = Animation(SPRITE_SHEET, 128, 128, 8, 0, 128)
local ANIM_JUMP = Animation(SPRITE_SHEET, 128, 128, 3, 0, 256)
local ANIM_MAGIC = Animation(SPRITE_SHEET, 128, 128, 2, 640, 256)
local ANIM_BUTT = Animation(SPRITE_SHEET, 128, 128, 3, 0, 384)
local ANIM_PAIN = Animation(SPRITE_SHEET, 128, 128, 1, 384, 384)
local ANIM_DEAD = Animation(SPRITE_SHEET, 128, 128, 1, 512, 384)

local MAGIC_SHEET = love.graphics.newImage("assets/sprites/magic.png")
local ANIM_MAGIC_START = Animation(MAGIC_SHEET, 256, 256, 5, 0, 0)
local ANIM_MAGIC_END = Animation(MAGIC_SHEET, 256, 256, 5, 1024, 0)

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
        ANIM_STAND, ANIM_WALK, ANIM_JUMP, ANIM_PAIN, ANIM_DEAD)
  end,
}
Player:include(Character)

--[[------------------------------------------------------------
Constants
--]]

-- physics
Player.MOVE_X = 5000.0
Player.MAX_DX = 1000.0
Player.BOOST = 1000.0
Player.GRAVITY = 1500.0
Player.FRICTION_X = 100

-- combat - light attack
Player.LIGHTATTACK = 
{
  REACH = 16,
  OFFSET_Y = 0,
  OFFSET_X = 0,
  DAMAGE = 35,
  MANA = 0,
  WARMUP_TIME = 0.2,
  DURATION = 0.1,
  RELOAD_TIME = 0.04,
  STUN_TIME = 1.0,
  W = 118,
  H = 108,
  KNOCKBACK = 1500,
  KNOCKUP = 450,
  ANIM_WARMUP = ANIM_BUTT,
  SOUND_HIT = "punch",
  SOUND_MISS = "miss",
  DIRECTIONAL = true,

  reloadTime = 0
}
-- combat - magic attack
Player.MAGICATTACK = 
{
  REACH = 0,
  OFFSET_Y = 0,
  OFFSET_X = -32,
  DAMAGE = 80,
  MANA = 30,
  WARMUP_TIME = 0.4,
  DURATION = 0.4,
  RELOAD_TIME = 0.3,
  STUN_TIME = 3.0,
  W = 350,
  H = 350,
  KNOCKBACK = 950,
  KNOCKUP = 1200,
  ANIM_WARMUP = ANIM_MAGIC,
  SFX_WARMUP = ANIM_MAGIC_START,
  SFX_LAUNCH = ANIM_MAGIC_END,
  DIRECTIONAL = false,
  SOUND_WARMUP = "magic",
  
  reloadTime = 0
}

Player.MAXMANA = 100
Player.MAXLIFE = 100
Player.SOUND_STUNNED = "disgust"

--[[------------------------------------------------------------
Collisions
--]]

function Player:die()
  audio:play_music("music_defeat")
  self:setState(self.STATE.DEAD)
end

function Player:collidesType(type)
  return ((type == GameObject.TYPE.ENEMY)
      or (type == GameObject.TYPE.ATTACK)
      or (type == GameObject.TYPE.DEATH)
      or (type == GameObject.TYPE.BONUS))
end

function Player:eventCollision(other, level)
  -- character collisions
  Character.eventCollision(self, other, level)
  
  -- collision with "bonus" 
  if other.type == GameObject.TYPE.BONUS then
    self.life = self.MAXLIFE
	self.magic = self.MAXMANA
    other.purge = true --! FIXME
  end
end

--[[------------------------------------------------------------
Game loop
--]]

function Player:update(dt, level, view)

  -- try attack
  if self.state == Character.STATE.NORMAL then
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
    -- launch attack
    if weapon and (weapon.reloadTime <= 0) then
      self:startAttack(weapon, nil, level, view)
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