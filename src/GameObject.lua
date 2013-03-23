--[[
(C) Copyright 2013 
William Dyce, Maxime Ailloud, Alex Averbrugghe, Julien Deville

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

local Class = require("hump/class")
local useful = require("useful")

--[[------------------------------------------------------------
GAMEOBJECT CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local GameObject = Class
{
  init = function(self, x, y)
    self.x        = x
    self.y        = y
  end,
  
  -- default attribute values
  w = 0,
  h = 0,
  dx = 0,
  dy = 0
}

--[[----------------------------------------------------------------------------
Types
--]]

GameObject.TYPE = {}

GameObject.TYPE["PLAYER"] = 1 
GameObject.TYPE[1] = "PLAYER"

GameObject.TYPE["ATTACK"] = 2
GameObject.TYPE[2] = "ATTACK"

GameObject.TYPE.ENEMY = 3
GameObject.TYPE[3] = "ENEMY"

--[[----------------------------------------------------------------------------
Collisions
--]]

function GameObject:snap_from_collision(dx, dy, tilegrid, max)
  local i = 0
  while tilegrid:collision(self) and (not max or i < max)  do
    self.x = self.x + dx
    self.y = self.y + dy
    i = i + 1
  end
end

function GameObject:snap_to_collision(dx, dy, tilegrid, max)
  local i = 0
  while not tilegrid:collision(self, self.x + dx, self.y + dy) 
        and (not max or i < max)  do
    self.x = self.x + dx
    self.y = self.y + dy
    i = i + 1
  end
end

function GameObject:eventCollision(other)
  -- override me!
end

function GameObject:collidesType(type)
  -- override me!
  return false
end

function GameObject:isColliding(other)
  
  -- no self collisions
  if self == other then
    return false
  end

  -- horizontally seperate ? 
  local v1x = (other.x + other.w) - self.x
  local v2x = (self.x + self.w) - other.x
  if useful.sign(v1x) ~= useful.sign(v2x) then
    return false
  end
  -- vertically seperate ?
  local v1y = (self.y + self.h) - other.y
  local v2y = (other.y + other.h) - self.y
  if useful.sign(v1y) ~= useful.sign(v2y) then
    return false
  end
  
  -- in every other case there is a collision
  return true
end


--[[------------------------------------------------------------
Game loop
--]]

function GameObject:update(dt, level)
  -- shortcut
  local tilegrid = level.tilegrid
  
  -- object may have several fisix settings
  local fisix = (self.fisix or self)
  
  -- gravity
  if fisix.GRAVITY and self.airborne then
    self.dy = self.dy + fisix.GRAVITY*dt
  end
  
  -- friction
  if fisix.FRICTION_X and (fisix.FRICTION_X ~= 0) then
    self.dx = self.dx / (math.pow(fisix.FRICTION_X, dt))
  end
  if fisix.FRICTION_Y and (fisix.FRICTION_Y ~= 0) then
    self.dy = self.dy / (math.pow(fisix.FRICTION_Y, dt))
  end
  
  -- terminal velocity
  local abs_dx, abs_dy = math.abs(self.dx), math.abs(self.dy)
  if fisix.MAX_DX and (abs_dx > fisix.MAX_DX) then
    self.dx = fisix.MAX_DX*useful.sign(self.dx)
  end
  if fisix.MAX_DY and (abs_dy > fisix.MAX_DY) then
    self.dy = fisix.MAX_DY*useful.sign(self.dy)
  end
  
  -- clamp less than epsilon inertia to 0
  if math.abs(self.dx) < 0.01 then self.dx = 0 end
  if math.abs(self.dy) < 0.01 then self.dy = 0 end
  
  
  -- check if we're on the ground
  self.airborne = 
    ((not tilegrid:pixelCollision(self.x, self.y + self.h + 1)
    and (not tilegrid:pixelCollision(self.x + self.w, self.y + self.h + 1))))
  if not self.airborne and self.dy > 0 then
    if tilegrid:collision(self) then
      self:snap_from_collision(0, -1, tilegrid, math.abs(self.dy))
    end
    self.dy = 0
  end 
  
  -- move HORIZONTALLY FIRST
  if self.dx ~= 0 then
    local move_x = self.dx * dt
    local new_x = self.x + move_x
  
    -- is new x in collision ?
    if tilegrid:collision(self, new_x, self.y) then
      -- move as far as possible towards new position
      self:snap_to_collision(useful.sign(self.dx), 0, 
                        tilegrid, math.abs(self.dx))
      self.dx = 0
    else
      -- if not move to new position
      self.x = new_x
    end
  end
  
  -- move the object VERTICALLY SECOND
  if self.dy ~= 0 then
    local move_y = self.dy*dt
    local new_y = self.y + move_y
    -- is new y position free ?
    if tilegrid:collision(self, self.x, new_y) then
      -- if not move as far as possible
      self:snap_to_collision(0, useful.sign(self.dy), tilegrid, math.abs(self.dy))
      self.dy = 0
    else
      -- if so move to new position
      self.y = new_y
    end
  end
end

function GameObject:draw()
  -- FIXME debug
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return GameObject