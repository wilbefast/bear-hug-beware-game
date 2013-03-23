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
    Character.init(self, x, y, "assets/sprites/HerosCourseSprite.png")
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
Player.MOVE_Y = 32.0
Player.MAX_DX = 1000.0
Player.BOOST = 850.0
Player.GRAVITY = 700.0
Player.FRICTION_X = 50
Player.w = 128
Player.h = 128
-- combat
Player.LIGHTATTACK_REACH = 200
Player.LIGHTATTACK_DAMAGE = 30
Player.LIGHTATTACK_RELOADTIME = 1
Player.HEAVYATTACK_REACH = 300
Player.HEAVYATTACK_DAMAGE = 80
Player.HEAVYATTACK_RELOADTIME = 1.7

--[[------------------------------------------------------------
Collisions
--]]

function Player:collidesType(type)
  return (type == GameObject.TYPE.ENEMY)
end

function Player:eventCollision(other)
  if other.reloadTime <= 0 then
    self:life_change(-other.DAMAGE)
    self.reloadTime = other.ATTACK_INTERVAL
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

    -- attack
    if self.requestLightAttack then
      level:addObject(Attack(self.x, self.y, 
          self.LIGHTATTACK_DAMAGE,
          self.LIGHTATTACK_W, 
          self.LIGHTATTACK_H))
      
      -- reset
      self.requestLightAttack = false
    end

    if self.requestHeavyAttack then
      print("request heavy attack")
      -- TODO

      -- reset
      self.requestHeavyAttack = false
    end

    if self.requestMagicAttack then
      print("request magic attack")
      -- TODO

      -- reset
      self.requestMagicAttack = false
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
end

return Player