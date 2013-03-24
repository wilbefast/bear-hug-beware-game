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
local Character   = require("character")
local GameObject  = require("GameObject")
local Attack      = require("Attack")
local useful      = require("useful")
local AnAl        = require("AnAL/AnAL")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialise
--]]

local Player = Class
{
  type  =  GameObject.TYPE["PLAYER"],

  init = function(self, x, y)
    Character.init(self, x, y, 64, 128, 
                    "assets/sprites/HerosSprite.png")
    self.animationmarche = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 1, 3, 5, 7, 9, 11, 13, 15 })
    self.animationmarche:setSpeed(1,2)
    self.animationsautdebut = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 21, 22 })
    self.animationsautdebut:setSpeed(1,2)
    self.animationsautdebut:setMode("once")
    self.animationsautmilieumontee = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 23 })
    self.animationsautmilieumontee:setSpeed(1,2)
    self.animationsautmilieumontee:setMode("once")
    self.animationsautmilieudescente = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 24 })
    self.animationsautmilieudescente:setSpeed(1,2)
    self.animationsautmilieudescente:setMode("once")
    self.animationsautfin = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 25, 26 })
    self.animationsautfin:setSpeed(1,2)
    self.animationsautfin:setMode("once")
    self.animationattaque = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 17, 18, 19 })
    self.animationattaque:setSpeed(1,2)
    self.animationattaque:setMode("once")
    self.animationtouched = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 20 })
    self.animationtouched:setSpeed(1,2)

	fond = love.image.newImageData("assets/decors/horizon.png")
   horizon = love.graphics.newImage(fond)
   plan_1 = love.image.newImageData("assets/decors/plan1.png")
   plan1 = love.graphics.newImage(plan_1)
   
    self.animationcurrent = self.animationmarche
    --marche self.animation:setAnimation({ 1, 3, 5, 7, 9, 11, 13, 15 })
    --saut self.animation:setAnimation({ 21, 22, 23, 24, 26 })
    --attaque self.animation:setAnimation({ 17, 18, 19 })
    --touched self.animation:setAnimation({ 20 })
    --self.animation:setSpeed(1,2)
	
	  fic_saut = "assets/audio/saut.ogg"
  saut = love.audio.newSource(fic_saut,"static")
  
end,
}
Player:include(Character)

--[[------------------------------------------------------------
Constants
--]]

-- physics
Player.MOVE_X = 50.0
Player.MAX_DX = 1000.0
Player.BOOST = 1000.0
Player.GRAVITY = 1500.0
Player.FRICTION_X = 50

-- combat - light attack
Player.LIGHTATTACK = 
{
  REACH = 80,
  OFFSET_Y = 32,
  DAMAGE = 30,
  MANA = 0,
  RELOAD_TIME = 0.5,
  W = 40,
  H = 40,
  KNOCKBACK = 300,
  KNOCKUP = 150,
  
  reloadTime = 0
}
-- combat - magic attack
Player.MAGICATTACK = 
{
  REACH = 32,
  OFFSET_Y = 32,
  DAMAGE = 10,
  MANA = 10,
  RELOAD_TIME = 4.0,
  W = 256,
  H = 256,
  KNOCKBACK = 600,
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
    self:life_change(-other.weapon.DAMAGE)
    -- knock-back
    push = useful.sign(self:centreX() - other.launcher:centreX())
    self.dx = self.dx + push * other.weapon.KNOCKBACK
  
  -- collision with "death" (bottomless pit)
  elseif other.type == GameObject.TYPE.DEATH then
    self.life = 0

  -- collision with "bonus" 
  elseif other.type == GameObject.TYPE.BONUS then
    self.life = 100
	self.magic = self.MAXMANA
    other.purge = true --! FIXME
  end
end

--[[------------------------------------------------------------
Combat
--]]

function Player:attack(weapon)
  weapon.reloadTime = weapon.RELOAD_TIME

  self:magic_change(-weapon.MANA)

  return (Attack(
    self.x + self.w/2 + weapon.REACH*self.facing,
    self.y + weapon.OFFSET_Y, weapon, self))
end

function reload(weapon, dt)
  weapon.reloadTime = math.max(0, weapon.reloadTime - dt)
end

--[[------------------------------------------------------------
Game loop
--]]

function Player:update(dt, level)
  --update player only if alive
  if self.life > 0 then
    
    -- accelerate
    local moveDir = useful.sign(self.requestMoveX)
    if moveDir ~= 0 then
      self.dx = self.dx + moveDir*self.MOVE_X
      self.facing = moveDir
    end

    -- jump
    if self.requestJump then
      -- check if on the ground
      if (not self.airborne) then
        self.dy = -Player.BOOST
		saut:play()
      end
    end

    if self.airborne then
      if( useful.sign(self.dy) > 0 ) then
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
	

    -- attack
    local weapon = nil
    -- ... light
    if self.requestLightAttack then
      weapon = self.LIGHTATTACK

    end
    -- ... magic
    if self.requestMagicAttack then
      weapon = self.MAGICATTACK
    end

	if self.animationcurrent == self.animationattaque and not self.animationattaque:isPlaying() then
	  self.animationcurrent = self.animationmarche
	  self.animationcurrent:play()
	end
	if weapon and (weapon.reloadTime <= 0) then
      level:addObject(self:attack(weapon))
	  	  self.animationcurrent = self.animationattaque
        self.animationcurrent:reset()
	  self.animationcurrent:play()
	elseif( not self.airborne and self.animationcurrent ==  self.animationmarche )then
      if self.requestMoveX ~= 0 then

      else
        self.animationcurrent = self.animationmarche
        self.animationcurrent:seek(8)
      end
    end
	
    self.animationcurrent:update(dt)


    
    -- reload weapons
    reload(self.LIGHTATTACK, dt)
    reload(self.MAGICATTACK, dt)
    
    -- reset input requests to false
    self.requestMoveX, self.requestMoveY = 0, 0
    self.requestJump = false
    self.requestLightAttack = false
    self.requestMagicAttack = false

    -- base update
    Character.update(self, dt, level)
  end

end

function Player:draw()
  local x = self.x - 32*self.facing
  if self.facing < 0 then
    x = x + self.w
  end
  self.animationcurrent:draw(x, self.y + 16, 0, self.facing, 1)
  
  
  -- FIXME debug
  GameObject.draw(self)
  
  love.graphics.print(self.LIGHTATTACK.reloadTime, self.x, self.y)
  love.graphics.print(self.MAGICATTACK.reloadTime, self.x, self.y+40)
end

return Player