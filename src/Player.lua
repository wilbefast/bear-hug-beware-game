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
local SpecialEffect = require("SpecialEffect")

--[[------------------------------------------------------------
PLAYER CLASS
--]]------------------------------------------------------------

local SPRITE_SHEET = love.graphics.newImage("assets/sprites/hero.png")
local ANIM_WALK = Animation(SPRITE_SHEET, 128, 128, 8)
local ANIM_STAND = Animation(SPRITE_SHEET, 128, 128, 8, 0, 128)
local ANIM_JUMP = Animation(SPRITE_SHEET, 128, 128, 3, 0, 256)
local ANIM_CROUCH = Animation(SPRITE_SHEET, 128, 128, 2, 384, 256)
local ANIM_MAGIC = Animation(SPRITE_SHEET, 128, 128, 2, 640, 256)
local ANIM_BUTT = Animation(SPRITE_SHEET, 128, 128, 3, 0, 384)
local ANIM_PAIN = Animation(SPRITE_SHEET, 128, 128, 1, 384, 384)
local ANIM_DEAD = Animation(SPRITE_SHEET, 128, 128, 1, 512, 384)
local QORB = love.graphics.newQuad(896, 256, 64, 64,
  SPRITE_SHEET:getWidth(), SPRITE_SHEET:getHeight())
local ANIM_ORB_IN = Animation(SPRITE_SHEET, 32, 32, 4, 896, 320)
local ANIM_ORB_OUT = Animation(SPRITE_SHEET, 32, 32, 4, 896, 352)
local ANIM_ORB_ABSORB = Animation(SPRITE_SHEET, 128, 128, 3, 640, 384)

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
        ANIM_STAND, ANIM_WALK, ANIM_JUMP, ANIM_PAIN, ANIM_DEAD, ANIM_CROUCH)
    
    -- combos
    self.score = 0
    self.combo = 0
    self.combo_timer = 0
    self.orb_offset = math.random()*math.pi*2
  end,
}
Player:include(Character)

--[[------------------------------------------------------------
Constants
--]]

-- physics
Player.MOVE_X = 5000.0
Player.MAX_DX = 1000.0
Player.BOOST = 0.0
Player.BOOST_MIN = 500.0
Player.BOOST_MAX = 1300.0
Player.GRAVITY = 1500.0
Player.FRICTION_X = 100

--[[------------------------------------------------------------
Combat
--]]

local COMBO_DURATION = 2

local COMBO_HIT_VALUE = 1
local COMBO_JUGGLE_VALUE = 2
local COMBO_KILLHIT_VALUE = 3
local COMBO_JUMPATTACK_VALUE = 1.5

local COMBO_MAX = 10

local COMBO_MAGIC_BONUS = 4
local COMBO_LIFE_BONUS = 1
local COMBO_SCORE_BONUS = 10

local COMBO_MISS_PENALTY = 0.6

function Player:getOrbPosition(orb_i)
  local ang = orb_i  * (2*math.pi / self.combo) 
                    + self.orb_offset
  local rad = 64 + self.combo_timer*32
  return self:centreX() + math.cos(ang)*rad, 
          self:centreY() + math.sin(ang)*rad
end

function Player:onAttacked(attack, level)
  if self.combo > 0 then
    self:onComboEnd(level)
  end
end

function Player:onHit(weapon, attack, level)
  
  local dcombo = 1
  
  self:comboBonus((attack.n_hit*COMBO_HIT_VALUE 
            + attack.n_hit_air*COMBO_JUGGLE_VALUE  
            + attack.n_kills*COMBO_KILLHIT_VALUE) 
    * useful.tri(self.airborne, COMBO_JUMPATTACK_VALUE, 1), level)

  -- reset combo
  self.combo = self.combo + dcombo
  self.combo_timer = COMBO_DURATION
  
  -- cap combo
  if self.combo > COMBO_MAX then
    self.combo = COMBO_MAX
  end
  audio:play_sound("punch", nil, nil, nil, 1+(self.combo/COMBO_MAX))
  
  
  -- create 'orb appear' sfx
  for i = 1, dcombo do
    local x, y = self:getOrbPosition(self.combo - i)
    level:addObject(SpecialEffect(x, y, ANIM_ORB_IN, 10))
  end
end

function Player:onMiss(weapon, level)
  -- reduce combo time on miss
  if self.combo > 0 then
    self.combo_timer = self.combo_timer * COMBO_MISS_PENALTY
  end
end

function Player:comboBonus(amount, level)
  self:addMagic(self.combo * COMBO_MAGIC_BONUS)
  self:addLife(self.combo * COMBO_LIFE_BONUS)
  self.score = self.score + self.combo * COMBO_SCORE_BONUS
end

function Player:onComboEnd(level)
  -- create 'orb die' sfx
  for i = 1, self.combo do
    local x, y = self:getOrbPosition(i)
    level:addObject(SpecialEffect(x, y, ANIM_ORB_OUT, 10))
  end
  -- reset combo with giving points or mana
  self.combo = 0
end

local ON_HIT = function(weapon, owner, attack, level) 
  owner:onHit(weapon, attack, level) end
local ON_MISS = function(weapon, owner, attack, level) 
  owner:onMiss(weapon, attack, level) end

-- combat - light attack
Player.LIGHTATTACK = 
{
  REACH = 16,
  OFFSET_Y = 0,
  OFFSET_X = 0,
  DAMAGE = 34,
  MANA = 0,
  WARMUP_TIME = 0.1,
  DURATION = 0.1,
  RELOAD_TIME = 0.04,
  STUN_TIME = 1.0,
  W = 180,
  H = 108,
  KNOCKBACK = 1500,
  KNOCKUP = 450,
  ANIM_WARMUP = ANIM_BUTT,
  SOUND_MISS = "miss",
  --DIRECTIONAL = true,
  ON_HIT = ON_HIT,
  ON_MISS = ON_MISS,
        
  reloadTime = 0,
  charge = 0
}
-- combat - magic attack
Player.MAGICATTACK = 
{
  REACH = 0,
  OFFSET_Y = 0,
  OFFSET_X = -32,
  DAMAGE = 45,
  MANA = 30,
  WARMUP_TIME = 0.2,
  DURATION = 0.4,
  RELOAD_TIME = 0.3,
  STUN_TIME = 3.0,
  W = 350,
  H = 350,
  KNOCKBACK = 950,
  KNOCKUP = 1200,
  ANIM_WARMUP = ANIM_MAGIC,
  --SOUND_HIT = "punch",
  SFX_WARMUP = ANIM_MAGIC_START,
  SFX_LAUNCH = ANIM_MAGIC_END,
  DIRECTIONAL = false,
  SOUND_WARMUP = "magic",
  
  ON_HIT = ON_HIT,
  ON_MISS = ON_MISS,
  
  reloadTime = 0,
  charge = 0
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
    --self.magic = self.MAXMANA
    other.purge = true --! FIXME
  end
end

--[[------------------------------------------------------------
Game loop
--]]

function Player:update(dt, level, view)

  if self.state == Character.STATE.NORMAL then
    -- prepare jump
    if (not self.airborne) and self.requestStartJump then
      self:setState(Character.STATE.CROUCHING)

    -- prepare attack
    else
      local weapon = nil
      -- ... light
      if self.requestStartLightAttack then
        weapon = self.LIGHTATTACK
      -- ... magic
      elseif self.requestStartMagicAttack then
        if (self.magic >= self.MAGICATTACK.MANA) then
          weapon = self.MAGICATTACK
        end
      end
      -- launch attack
      if weapon and (weapon.reloadTime <= 0) then
        self:backswingAttack(weapon, nil, level, view)
      end
    end
    
  -- launch attack 
  elseif self.state == Character.STATE.BACKSWING then
    local weapon = nil
    -- ... light
    if self.requestLightAttack then
      weapon = self.LIGHTATTACK
    end
    -- ... magic
    if self.requestMagicAttack then
      weapon = self.MAGICATTACK
    end
    -- launch attack
    if weapon and (weapon.reloadTime <= 0) then
      self:setState(Character.STATE.WARMUP, 
                    (weapon.WARMUP_TIME or 0))
    end
  end

  -- countdown combo
  if (self.combo > 0) then
    if (self.combo_timer > 0) then
      self.combo_timer = self.combo_timer - dt
    else
      self:onComboEnd(level)
    end
  end
  
  -- rotate combo orbs
  self.orb_offset = self.orb_offset + dt*4
  if self.orb_offset > math.pi*2 then
    self.orb_offset = self.orb_offset - math.pi*2
  end
        
  -- reload weapons
  function reload(weapon, dt)
    weapon.reloadTime = math.max(0, weapon.reloadTime - dt)
  end
  reload(self.LIGHTATTACK, dt)
  reload(self.MAGICATTACK, dt)
  
  -- reset input
  self.requestStartLightAttack = false
  self.requestStartMagicAttack = false
  self.requestLightAttack = false
  self.requestMagicAttack = false
  
  -- base update
  Character.update(self, dt, level)
end

function Player:draw()
  
  -- draw sprite
  Character.draw(self)
  
  -- draw combo orbs
  for i = 1, self.combo do
    local x, y = self:getOrbPosition(i)
    love.graphics.drawq(SPRITE_SHEET, QORB, x-32, y-32)
  end
  
  love.graphics.print(tostring(self.BOOST), self.x, self.y+128)
  
end

return Player