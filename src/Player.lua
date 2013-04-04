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
--local AnAl        = require("AnAL/AnAL")
local Animation   = require("Animation")
local AnimationView = require("AnimationView")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------

local SPRITE_SHEET = love.graphics.newImage("assets/sprites/hero.png")
local ANIM_WALK = Animation(SPRITE_SHEET, 128, 128, 8)
local ANIM_STAND = Animation(SPRITE_SHEET, 128, 128, 8, 0, 128)
local ANIM_JUMP = Animation(SPRITE_SHEET, 128, 128, 6, 0, 256)
local ANIM_MAGIC = Animation(SPRITE_SHEET, 128, 128, 2, 768, 256)
local ANIM_BUTT = Animation(SPRITE_SHEET, 128, 128, 3, 0, 384)
local ANIM_PAIN = Animation(SPRITE_SHEET, 128, 128, 1, 384, 384)
local ANIM_DEAD = Animation(SPRITE_SHEET, 128, 128, 1, 512, 384)
--[[
self.animationmarche = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 1, 2, 3, 4, 5, 6, 7, 8 })
self.animationmarche:setSpeed(1,2)
self.animationsautdebut = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 17, 18 })
self.animationsautdebut:setSpeed(1,2)
self.animationsautdebut:setMode("once")
self.animationsautmilieumontee = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 19 })
self.animationsautmilieumontee:setSpeed(1,2)
self.animationsautmilieumontee:setMode("once")
self.animationsautmilieudescente = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 20 })
self.animationsautmilieudescente:setSpeed(1,2)
self.animationsautmilieudescente:setMode("once")
self.animationsautfin = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 21, 22 })
self.animationsautfin:setSpeed(1,2)
self.animationsautfin:setMode("once")
self.animationattaque = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 25, 26, 27 })
self.animationattaque:setSpeed(1,2)
self.animationattaque:setMode("once")
self.animationtouched = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 28 })
self.animationtouched:setSpeed(1,2)
self.animationtouched:setMode("once")
self.animationattaquemagic = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 23, 24 })
self.animationattaquemagic:setSpeed(1,2)
self.animationattaquemagic:setMode("once")
self.animationwaiting = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 9, 10, 11, 12, 13, 14, 15, 16 })
self.animationwaiting:setSpeed(1,2)
self.animationdead = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 29 })
self.animationdead:setSpeed(1,2)
self.animationdead:setMode("once") --]]

--[[------------------------------------------------------------
Initialise
--]]

local Player = Class
{
  type  =  GameObject.TYPE["PLAYER"],

  -- constructor
  init = function(self, x, y)
  
    ---- Character
    Character.init(self, x, y, 64, 128, SPRITE_SHEET)
    
    ---- animation
    self.view = AnimationView(ANIM_STAND)
    
    --self.animationcurrent = self.animationmarche

  --[[
  im = love.graphics.newImage("assets/hud/spriteVie.png")
  self.barre_life = newAnimation(im, 186, 62, 0.1, 0, 0, 0, {1,2,3,4,5,6,7,8,9})
  self.barre_life:setMode("once")
  self.barre_mana = newAnimation(im, 186, 62, 0.1, 0, 0, 0, {10})
  self.barre_mana:setMode("once")
    --marche self.animation:setAnimation({ 1, 3, 5, 7, 9, 11, 13, 15 })
    --saut self.animation:setAnimation({ 21, 22, 23, 24, 26 })
    --attaque self.animation:setAnimation({ 17, 18, 19 })
    --touched self.animation:setAnimation({ 20 })
    --self.animation:setSpeed(1,2)
	self.barre_life:seek(1)
  saut = love.audio.newSource("assets/audio/saut.ogg", "static")
  self.life=90 --]]
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
Game loop
--]]

function Player:update(dt, level)

  ------------- ACCELERATE ---------------------
  local moveDir = useful.sign(self.requestMoveX)
  if moveDir ~= 0 then
    self.dx = self.dx + moveDir*self.MOVE_X*dt
    self.facing = moveDir
  end

  ------------- JUMP ---------------------
  if self.requestJump then
    -- check if on the ground
    if (not self.airborne) then
      self.dy = -Player.BOOST
    end
  end

  ------------- ATTACK ---------------------
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
        
  ------------- RELOAD ---------------------
  function reload(weapon, dt)
    weapon.reloadTime = math.max(0, weapon.reloadTime - dt)
  end
  reload(self.LIGHTATTACK, dt)
  reload(self.MAGICATTACK, dt)
  
  ------------- RESET INPUT REGISTERS ---------------------
  self.requestMoveX, self.requestMoveY = 0, 0
  self.requestJump = false
  self.requestLightAttack = false
  self.requestMagicAttack = false

  ------------- BASE UPDATE ---------------------
  Character.update(self, dt, level)
end
          
    --[[    
          
          
          
          ------ANIMATION LOGIC--------
          if self.requestLightAttack then
            self.animationcurrent = self.animationattaque
          elseif self.requestMagicAttack then
            self.animationcurrent = self.animationattaquemagic
          end
          self.animationcurrent:reset()
          self.animationcurrent:play()
        elseif( not self.airborne and self.animationcurrent ==  self.animationmarche or self.animationcurrent ==  self.animationwaiting)then
          if self.requestMoveX ~= 0 then
            self.animationcurrent = self.animationmarche
            self.animationcurrent:play()
          else
            self.animationcurrent = self.animationwaiting
            self.animationcurrent:play()
          end
      end

      
      
      
      ------ANIMATION LOGIC--------
      if self.baffed then
        self.animationcurrent = self.animationtouched
          self.animationcurrent:reset()
        self.animationtouched:play()
        self.baffed = false
      end
    end
    
        if self.airborne then
      if( useful.sign(self.dy) > 0 ) and (self.warmupTime <= 0) then
        self.animationcurrent = self.animationsautmilieudescente
        self.animationsautmilieudescente:play()
      end

      if( self.animationcurrent ==  self.animationsautdebut and not self.animationsautdebut:isPlaying() ) then
        self.animationcurrent = self.animationsautmilieumontee
        self.animationsautmilieumontee:play()
      end
      if( self.animationcurrent ==  self.animationmarche) then
        if( useful.sign(self.requestMoveY) < 0 ) then
          self.animationcurrent = self.animationsautdebut
          self.animationsautdebut:play()
        else
          self.animationcurrent = self.animationsautmilieudescente
          self.animationsautmilieudescente:play()
        end
      end

    end
    if( self.animationcurrent ==  self.animationsautfin and not self.animationsautfin:isPlaying() ) then
      self.animationcurrent = self.animationmarche
      self.animationmarche:play()
    end
    if( not self.airborne and self.animationcurrent ==  self.animationsautmilieudescente) then
      self.animationcurrent = self.animationsautfin
      self.animationsautfin:play()
    end

    self.animationcurrent:update(dt) 

  else
    self.animationcurrent = self.animationdead
    self.animationcurrent:reset()
    self.animationcurrent:play()
  end 

end--]]

function Player:draw()
  Character.draw(self)
  --local x = self.x + useful.tri(self.facing < 0, self.w - 32, 32)
  --self.animationcurrent:draw(x, self.y + 16, 0, self.facing, 1)
end

return Player