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

-- combat
Enemy.ATTACK =
{
  REACH = 0,
  OFFSET_Y = 0,
  OFFSET_X = 0,
  DAMAGE = 10,
  MANA = 0,
  WARMUP_TIME = 0.5,
  RELOAD_TIME = 0.4,
  STUN_TIME = 0.5,
  DURATION = 0.1,
  W = 118,
  H = 108,
  KNOCKBACK = 700,
  KNOCKUP = 300,
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
Enemy.TURN_DIST = 100
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
  local dist = math.abs(delta_x)
  
  -- can see player?
  if inView or self.aggro then
    
    -- once active, follow the player TO THE ENDS OF THE EARTH!
    self.aggro = true
    
    -- desire move?
    if (dist > self.TURN_DIST) then
      self.requestMoveX = useful.sign(delta_x)
    -- ... stop
    else
      self.requestMoveX = 0
    end
    
    -- desire attack?
    if (dist < self.ATTACK_DIST) 
    and (useful.sign(self.facing) == useful.sign(delta_x))
    and (self.state == self.STATE.NORMAL)
    and (self.reloadTime <= 0)
    then
      self:startAttack(self.ATTACK, player)
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