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
local DeadEnemy   = require("DeadEnemy")

--[[------------------------------------------------------------
ENEMY CLASS
--]]------------------------------------------------------------

local SPRITE_SHEET = love.graphics.newImage("assets/sprites/enemy.png")

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
  Character.init(self, x, y, w, h, SPRITE_SHEET)
  self.requestJump = false
  self.requestMoveX = 0

  self.animationmarche = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 1, 2, 3, 4, 5, 6 })
  self.animationmarche:setSpeed(1,2)

  self.animationtouched = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 7 })
  self.animationtouched:setSpeed(1,2)
  self.animationtouched:setMode("once")

  self.animationcurrent = self.animationmarche

  self.stunned = false
  cri_mort = love.audio.newSource("assets/audio/cri_mort.ogg", "static")

end

-- fisix
Enemy.GRAVITY    = 1200
Enemy.BOOST      = 700
Enemy.MOVE_X     = 4000.0
Enemy.MAX_DX     = 700.0
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

  self.animationmarche = newAnimation(love.graphics.newImage("assets/sprites/EnnemiWalkerSpriteBlood.png"), 128, 128, 0.1, 0, 0, 0, { 1, 2, 3, 4, 5, 6 })
  self.life = newLife
end

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

    self.stunnedTime = other.weapon.STUN_TIME

    self.baffed = true
    
    -- lost life
    self:life_change(-other.weapon.DAMAGE, level)
  
  -- collision with player
  elseif other.type == GameObject.TYPE.PLAYER then
    self.facing = useful.tri(other:centreX() > self:centreX(), 1, -1)
    if self.reloadTime <= 0 and self.warmupTime <= 0 then
      self:startAttack(self.ATTACK, other)
    end
  
  -- collision with death
  elseif other.type == GameObject.TYPE.DEATH then
    self:life_change(-math.huge, level)
  
  -- collision with other enemy
  elseif other.type == GameObject.TYPE.ENEMY then
    push = (self.w+other.w)/(self:centreX() - other:centreX())
    self.dx = self.dx + push * 10
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



    local moveDir = useful.sign(self.requestMoveX)
    if moveDir ~= 0 then
      self.dx = self.dx + moveDir*self.MOVE_X*dt
      self.facing = moveDir
    end

    -- jump
    if self.requestJump then
      -- check if on the ground
      if (not self.airborne) then
        self.dy = -Enemy.BOOST
      end
    end

    self.requestJump = false

  end

  if self.animationcurrent == self.animationtouched and not self.animationtouched:isPlaying()
  then
    self.animationcurrent = self.animationmarche
    self.animationcurrent:play()
  end

  if self.baffed then
    self.animationcurrent = self.animationtouched
    self.animationcurrent:reset()
    self.animationcurrent:play()
    self.baffed = false
  end

  self.animationcurrent:update(dt)
  
  -- base update
  Character.update(self, dt, level)
end



function Enemy:draw()
  local x = self.x + 96 * self.facing
  if self.facing < 0 then
    x = x + self.w
  end
  self.animationcurrent:draw(x, self.y + 16, 0, -self.facing, 1)


  -- FIXME debug
  --GameObject.draw(self)
  
  --love.graphics.print(self.warmupTime, self.x, self.y)

  --love.graphics.print(self.LIGHTATTACK.reloadTime, self.x, self.y)
  --love.graphics.print(self.MAGICATTACK.reloadTime, self.x, self.y+40)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Enemy