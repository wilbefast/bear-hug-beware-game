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
local GameObject = require("GameObject")
local Attack    = require("Attack")

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
    Character.update(self, dt, level)
  end

  local hauteur = love.graphics.getHeight() / 2
  local largeur = love.graphics.getWidth() / 2

  local cam_x = self.x
  local cam_y = self.y

  local levelh = level.tilegrid.h  * level.tilegrid.tileh
  local levelw = level.tilegrid.w  * level.tilegrid.tilew

  if self.x <= largeur then
    cam_x = largeur
  end
  if( self.x >= levelw - largeur ) then
    cam_x = levelw - largeur
  end

  if self.y <= hauteur then
    cam_y = hauteur
  end
  if( self.y >= levelh - hauteur ) then
    cam_y = levelh - hauteur
  end

  self.camera:lookAt( cam_x, cam_y )
end


return Player