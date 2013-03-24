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

local Character   = require("character")
local GameObject  = require("GameObject")
local Class       = require("hump/class")
local Timer       = require("hump.timer")

--[[------------------------------------------------------------
DeadEnemy CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialise
--]]
local DeadEnemy = Class
{
  type = GameObject.TYPE["DEADENEMY"]
}
DeadEnemy:include(Character)

function DeadEnemy:init(x, y, w, h)
  -- base constructor
  Character.init(self, x, y, w, h, "assets/sprites/EnnemiWalkerSprite.png")

  self.animationdead = newAnimation(self.image, 128, 128, 0.1, 0, 0, 0, { 7 })
  self.animationdead:setSpeed(1,2)
  self.animationdead:setMode("once")

  Timer.add(1, function() self.purge = true end)
end

-- fisix
DeadEnemy.GRAVITY    = 1500
DeadEnemy.FRICTION_X = 50



--[[------------------------------------------------------------
Collisions
--]]

function DeadEnemy:collidesType(type)
end

function DeadEnemy:eventCollision(other, level)
end

--[[------------------------------------------------------------
Combat
--]]

function DeadEnemy:attack(attack)
end

--[[------------------------------------------------------------
Game loop
--]]

function DeadEnemy:update(dt, level)
  self.animationdead:update(dt)

  Timer.update(dt)
  -- base update
  Character.update(self, dt, level)
end

function DeadEnemy:draw()
  local x = self.x + 96 * self.facing
  if self.facing < 0 then
    x = x + self.w
  end
  self.animationdead:draw(x, self.y + 16, 0, -self.facing, 1)

  -- FIXME debug
--  GameObject.draw(self)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return DeadEnemy