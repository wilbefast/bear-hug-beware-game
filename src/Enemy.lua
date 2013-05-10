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

local ANIM_STAND = 
  Animation(SPRITE_SHEET, 128, 128, 6, 0, 0)
local ANIM_JUMP = 
  Animation(SPRITE_SHEET, 128, 128, 3, 0, 128)
local ANIM_PAIN = 
  Animation(SPRITE_SHEET, 128, 128, 2, 768, 0)
local ANIM_ATTACK = 
  Animation(SPRITE_SHEET, 128, 128, 3, 384, 128)
  
--[[------------------------------------------------------------
Initialise
--]]
local Enemy = Class
{
  type  =  GameObject.TYPE["ENEMY"],
  reloadTime = 0
}
Enemy:include(Character)

function Enemy:init(x, y, w, h)
  -- base constructor
  Character.init(self, x, y, w, h, 
      ANIM_STAND, ANIM_STAND, ANIM_JUMP, ANIM_PAIN)

end

-- fisix
Enemy.GRAVITY    = 1200
Enemy.BOOST      = 700
Enemy.MOVE_X     = 3000.0
Enemy.MAX_DX     = 3000.0
Enemy.FRICTION_X = 50

-- giblets
Enemy.BLOOD = SPRITE_SHEET
Enemy.QBLOOD_DROP = {}
for i = 1, 4 do
  Enemy.QBLOOD_DROP[i] = love.graphics.newQuad(768 + (i-1)*32, 128, 32, 32,
    SPRITE_SHEET:getWidth(), SPRITE_SHEET:getHeight())
end
Enemy.QBLOOD_PUDDLE = {}
for i = 1, 4 do
  Enemy.QBLOOD_PUDDLE[i] = love.graphics.newQuad(768 + ((i-1)%2)*64, 
      160 + math.floor((i-1)/2)*16, 64, 16,
    SPRITE_SHEET:getWidth(), SPRITE_SHEET:getHeight())
end

Enemy.CORPSE = SPRITE_SHEET
Enemy.QCORPSE_AIR = love.graphics.newQuad(768, 192, 64, 64,
    SPRITE_SHEET:getWidth(), SPRITE_SHEET:getHeight())
Enemy.QCORPSE_GROUND = love.graphics.newQuad(896, 224, 128, 32,
    SPRITE_SHEET:getWidth(), SPRITE_SHEET:getHeight())
Enemy.QCORPSE_HEAD = love.graphics.newQuad(896, 128, 128, 96,
    SPRITE_SHEET:getWidth(), SPRITE_SHEET:getHeight())

-- combat
Enemy.ATTACK =
{
  DIRECTIONAL = true,
  REACH = 32,
  OFFSET_Y = 0,
  OFFSET_X = 0,
  DAMAGE = 10,
  MANA = 0,
  WARMUP_TIME = 0.5,
  RELOAD_TIME = 0.4,
  STUN_TIME = 0.3,
  DURATION = 0.1,
  W = 52,
  H = 52,
  KNOCKBACK = 1000,
  KNOCKUP = 400,
  ANIM_WARMUP = ANIM_ATTACK,
  SOUND_WARMUP = "bear_attack",
  ON_MISS = function(weapon, launcher)
    if (not launcher.airborne) then
      launcher:setState(Character.STATE.STUNNED, 0.5)
    end
  end
}

-- ai
Enemy.PERCENT_JUMPING = 0.1
Enemy.SIGHT_DIST = 800
Enemy.TURN_DIST = 125
Enemy.AI_H_DIST = 200
Enemy.ATTACK_DIST = Enemy.ATTACK.REACH + Enemy.ATTACK.W/2

--[[------------------------------------------------------------
Collisions
--]]

function Enemy:die()
  self.purge = true
  audio:play_sound("bear_die", 0.2, self.x, self.y)
end

function Enemy:collidesType(type)
  return ((type == GameObject.TYPE.PLAYER)
      or (type == GameObject.TYPE.ATTACK)
      or (type == GameObject.TYPE.DEATH)
      or (type == GameObject.TYPE.ENEMY))
end

--[[------------------------------------------------------------
Game loop
--]]

function Enemy:update(dt, level, view)

  -- AI
  local inView = self:isColliding(view)
  local player = level:getObject(GameObject.TYPE.PLAYER)
  local delta_x = player:centreX() - self:centreX()
  local delta_y = player:centreY() - self:centreY()
  local dist_x, dist_y = math.abs(delta_x), math.abs(delta_y)
  
  -- can see player?
  if inView or self.aggro then
    
    -- once active, follow the player TO THE ENDS OF THE EARTH!
    self.aggro = true
    
    -- desire move?
    if (dist_y < self.AI_H_DIST) 
    and (dist_x > self.TURN_DIST) then
      self.requestMoveX = useful.sign(delta_x)
    -- descend from ledge?
    elseif dist_y > self.AI_H_DIST then
      self.requestMoveX = self.facing
      self.requestMoveY = useful.sign(delta_y)
    -- slow to a halt?
    elseif (dist_x < self.ATTACK_DIST)
    and (not self.airborne)
    and (useful.sign(delta_x) == useful.sign(self.dx)) then
      self.dx = self.dx * 0.7
      self.requestMoveX = 0
    -- keep going in the same direction
    else  
      self.requestMoveX = self.facing
    end
    
    -- desire attack?
    if (dist_x < self.ATTACK_DIST) 
    and (dist_y < self.AI_H_DIST) 
    and (useful.sign(self.facing) == useful.sign(delta_x))
    and (self.state == self.STATE.NORMAL)
    and (self.reloadTime <= 0)
    then
      self:startAttack(self.ATTACK, player, level, view)
    end
    
    -- desire jump?
    local delta_y = self.y - player.y
    if delta_y > 0 then
      if (delta_y > player.h*2) 
      or ((delta_y / player.h / 2 * self.PERCENT_JUMPING) > math.random() ) then
        self.requestJump = true
      end
    end
  
    -- face player
    if math.abs(delta_y) < self.h then
      self.facing = useful.sign(delta_x)
    end
  
  else
    -- stop if not aggro, if not player in view
    self.requestMoveX = 0
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