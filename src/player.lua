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

	fond = love.image.newImageData("assets/decors/horizon.png")
   horizon = love.graphics.newImage(fond)
   plan_1 = love.image.newImageData("assets/decors/plan1.png")
   plan1 = love.graphics.newImage(plan_1)
   fichier="assets/audio/calin.ogg"
  calin = love.audio.newSource(fichier,"static")
   son_explosion = "assets/audio/explosion_magique.ogg"
  explosion = love.audio.newSource(son_explosion,"static")
    self.animationcurrent = self.animationmarche
	path = "assets/audio/prise_de_degats.ogg"
  baffe= love.audio.newSource(path, "static")
  
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
Player.MOVE_X = 3000.0
Player.MAX_DX = 1000.0
Player.BOOST = 1000.0
Player.GRAVITY = 1500.0
Player.FRICTION_X = 50

-- combat - light attack
Player.LIGHTATTACK = 
{
  TYPE = "light",
  REACH = 32,
  OFFSET_Y = 74,
  OFFSET_X = 0,
  DAMAGE = 35,
  MANA = 0,
  WARMUP_TIME = 0.2,
  RELOAD_TIME = 0.04,
  STUN_TIME = 0.5,
  W = 118,
  H = 108,
  KNOCKBACK = 3000,
  KNOCKUP = 150,
  
  reloadTime = 0
}
-- combat - magic attack
Player.MAGICATTACK = 
{
  TYPE = "magic",
  REACH = 0,
  OFFSET_Y = 64,
  OFFSET_X = -32,
  DAMAGE = 20,
  MANA = 10,
  WARMUP_TIME = 0.4,
  RELOAD_TIME = 0.3,
  STUN_TIME = 1,
  W = 256,
  H = 256,
  KNOCKBACK = 7000,
  KNOCKUP = 400,
  
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
	  calin:play()
    self.baffed = true
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
Game loop
--]]

function Player:update(dt, level)
  --update player only if alive
  if self.life > 0 then
    
    -- accelerate
    local moveDir = useful.sign(self.requestMoveX)
    if moveDir ~= 0 then
      self.dx = self.dx + moveDir*self.MOVE_X*dt
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

    -------------ATTACK---------------------
    if self.warmupTime <= 0 then
      -- attack
    	local weapon = nil
    	-- ... light
    	if self.requestLightAttack then
      	weapon = self.LIGHTATTACK
      	baffe:play()
    	end
    	-- ... magic
    	if self.requestMagicAttack then
      	if (self.magic >= self.MAGICATTACK.MANA) then
        	weapon = self.MAGICATTACK
          explosion:play()
      	end
    	end

      if self.animationcurrent == self.animationattaque and not self.animationattaque:isPlaying()
        or self.animationcurrent == self.animationattaquemagic and not self.animationattaquemagic:isPlaying()
        or self.animationcurrent == self.animationtouched and not self.animationtouched:isPlaying()
      then
        self.animationcurrent = self.animationmarche
        self.animationcurrent:play()
      end

      if weapon and (weapon.reloadTime <= 0) then
        
        
        
        
          ------GAMEPLAY LOGIC--------
          self:startAttack(weapon)
          
          
          
          
          
          
          
          
          
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
    
    ----------------------------------
    
    -- UPDATE ANIMATION
    self.animationcurrent:update(dt)

    -- reload weapons
    function reload(weapon, dt)
      weapon.reloadTime = math.max(0, weapon.reloadTime - dt)
    end
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
  --GameObject.draw(self)
  
  --love.graphics.print(self.LIGHTATTACK.reloadTime, self.x, self.y)
  --love.graphics.print(self.MAGICATTACK.reloadTime, self.x, self.y+40)
end

return Player