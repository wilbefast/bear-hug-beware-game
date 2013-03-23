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

local Class     = require("hump/class")
local Character = require("character")
local Attack    = require("Attack")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialise
--]]

local Player = Class
{
  type  = "player",

  init = function(self, x, y)
    Character.init(self, x, y, "assets/sprites/mur.png")
  end,
}
Player:include(Character)

--[[------------------------------------------------------------
Constants
--]]

Player.MOVE_X = 50.0
Player.MOVE_Y = 32.0
Player.MAX_DX = 1000.0
Player.BOOST = 850.0
Player.GRAVITY = 20.0
Player.FRICTION_X = 50
Player.w = 128
Player.h = 128

--[[------------------------------------------------------------
Collisions
--]]

function Player:eventCollision(other)
  if other.reloadTime <= 0 then
    self:life_change(-other.DAMAGE)
    self.reloadTime = other.ATTACK_INTERVAL
  end
end

--[[------------------------------------------------------------
Game loop
--]]

function Player:update(dt, tilegrid)
  -- TODO check if move is possible (stunned?)
  -- accelerate
  self.dx = self.dx + self.requestMoveX * self.MOVE_X

  --update player only if alive
  if self.life > 0 then
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
      print("request light attack")
      -- TODO


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

    -- reset input requests to false
    self.requestMoveX, self.requestMoveY = 0, 0

    -- base update
    Character.update(self, dt, tilegrid)
  end

  if self.x > 0 then
    self.camera:lookAt(self.x, self.y)
    self.camera:lookAt(self.x, self.y)
  else
    self.camera:lookAt(0, self.y)
  end
end


return Player