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
    Character.init(self, x, y, 128, 128, 
                    "assets/sprites/HerosCourseSprite.png")
  	self.animation = newAnimation(self.image, 128, 128, 0.1, 0)
    self.animation:setSpeed(1,2)
    self.facing = 1


end,
}
Player:include(Character)

--[[------------------------------------------------------------
Constants
--]]

-- physics
Player.MOVE_X = 50.0
Player.MAX_DX = 1000.0
Player.BOOST = 600.0
Player.GRAVITY = 1200.0
Player.FRICTION_X = 50

-- combat - light attack
Player.LIGHTATTACK = 
{
  REACH = 80,
  OFFSET_Y = 32,
  DAMAGE = 30,
  RELOAD_TIME = 0.5,
  W = 40,
  H = 40,
  KNOCKBACK = 300
}
-- combat - heavy attack
Player.HEAVYATTACK = 
{
  REACH = 110,
  OFFSET_Y = 32,
  DAMAGE = 50,
  RELOAD_TIME = 1.2,
  W = 50,
  H = 50,
  KNOCKBACK = 500
}
-- combat - magic attack
Player.MAGICATTACK = 
{
  REACH = 32,
  OFFSET_Y = 32,
  DAMAGE = 10,
  RELOAD_TIME = 4.0,
  W = 256,
  H = 256,
  KNOCKBACK = 600
}

--[[------------------------------------------------------------
Collisions
--]]

function Player:collidesType(type)
  return (type == GameObject.TYPE.ENEMY)
end

function Player:eventCollision(other)

end

--[[------------------------------------------------------------
Combat
--]]

function Player:attack(attack)
  self.reloadTime = attack.RELOAD_TIME
  return (Attack(
    self.x + self.w/2 + attack.REACH*self.facing,
    self.y + attack.OFFSET_Y, 
    attack.W, 
    attack.H,
    attack.DAMAGE,
    attack.KNOCKBACK))
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
      end

      -- reset
      self.requestJump = false
    end

    -- attack only if reloaded
    if self.reloadTime <= 0 then
      -- light attack
      if self.requestLightAttack then
        level:addObject(self:attack(self.LIGHTATTACK))
        -- reset
        self.requestLightAttack = false
      end
      -- heavy attack
      if self.requestHeavyAttack then
        level:addObject(self:attack(self.HEAVYATTACK))
        -- reset
        self.requestHeavyAttack = false
      end
      -- magic attack
      if self.requestMagicAttack then
        level:addObject(self:attack(self.MAGICATTACK))
        -- reset
        self.requestMagicAttack = false
      end
    end

    --update animation
    if self.requestMoveX ~= 0 then
      self.animation:update(dt)
    else
      self.animation:seek(1)
    end

    -- reset input requests to false
    self.requestMoveX, self.requestMoveY = 0, 0

    -- base update
    Character.update(self, dt, level)
  end

end

function Player:draw()
  local x = self.x
  if self.facing < 0 then
    x = self.x + self.w
  end
  self.animation:draw(x, self.y, 0, self.facing, 1)
  -- FIXME debug
  GameObject.draw(self)
  
  love.graphics.print(self.reloadTime, self.x, self.y)
end

return Player