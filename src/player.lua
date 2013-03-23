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
                    "assets/sprites/mur.png")
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

-- combat - light attack
Player.LIGHTATTACK_REACH = 200
Player.LIGHTATTACK_DAMAGE = 30
Player.LIGHTATTACK_RELOADTIME = 1
Player.LIGHTATTACK_W = 32
Player.LIGHTATTACK_H = 32
-- combat - heavy attack
Player.HEAVYATTACK_REACH = 300
Player.HEAVYATTACK_DAMAGE = 80
Player.HEAVYATTACK_RELOADTIME = 1.7
Player.LIGHTATTACK_W = 64
Player.LIGHTATTACK_H = 64

--[[------------------------------------------------------------
Collisions
--]]

function Player:collidesType(type)
  return (type == GameObject.TYPE.ENEMY)
end

function Player:eventCollision(other)

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
          self.LIGHTATTACK_W, 
          self.LIGHTATTACK_H,
          self.LIGHTATTACK_DAMAGE))
      
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
    Character.update(self, dt, level)
  end

end


return Player