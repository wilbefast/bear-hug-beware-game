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
local Tile = require("Tile")
local useful = require("useful")

--[[------------------------------------------------------------
GAMEOBJECT CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local GameObject = Class
{
  init = function(self, x, y, w, h)
    self.w        = (w or 0)
    self.h        = (h or 0)
    self.x        = x
    self.y        = y
    self.prevx    = self.x
    self.prevy    = self.y
  end,
  
  -- default attribute values
  dx = 0,
  dy = 0
}

--[[----------------------------------------------------------------------------
Types
--]]

GameObject.TYPE = {}

useful.bind(GameObject.TYPE, "GIBLET", 1)
useful.bind(GameObject.TYPE, "ATTACK", 2)
useful.bind(GameObject.TYPE, "ENEMY", 3)
useful.bind(GameObject.TYPE, "DEATH", 4)
useful.bind(GameObject.TYPE, "BONUS", 5)
useful.bind(GameObject.TYPE, "PLAYER", 6)
useful.bind(GameObject.TYPE, "DOODAD", 7)
useful.bind(GameObject.TYPE, "SPECIALEFFECT", 8)
useful.bind(GameObject.TYPE, "SCORE", 9)

function GameObject:typename()
  return GameObject.TYPE[self.type]
end

--[[----------------------------------------------------------------------------
Collisions
--]]

function GameObject:centreOn(x, y)
  self.x, self.y = x - self.w/2, y - self.h/2
end

function GameObject:centreX()
  return self.x + self.w/2
end

function GameObject:centreY()
  return self.y + self.h/2
end

function GameObject:snap_from_collision(dx, dy, collisiongrid, max, type)
  local i = 0
  while collisiongrid:collision(self, self.x, self.y, type) 
  and (not max or i < max)  do
    self.x = self.x + dx
    self.y = self.y + dy
    i = i + 1
  end
end

function GameObject:snap_to_collision(dx, dy, collisiongrid, max, type)
  local i = 0
  while not collisiongrid:collision(self, self.x + dx, self.y + dy, type) 
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
  local collisiongrid = level.collisiongrid
  
  -- object may have several fisix settings
  local fisix = (self.fisix or self)
  
  -- gravity
  if fisix.GRAVITY and self.airborne then
    self.dy = self.dy + fisix.GRAVITY*dt
  end
  
  -- friction
  if (self.dx ~= 0) and fisix.FRICTION_X and (fisix.FRICTION_X ~= 0) then
    self.dx = self.dx / (math.pow(fisix.FRICTION_X, dt))
  end
  if (self.dx ~= 0) and fisix.FRICTION_Y and (fisix.FRICTION_Y ~= 0) then
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
  
  -- collide with one-way platforms?
  local collide_type
  if (not collisiongrid:collision(self, self.x, self.prevy, Tile.TYPE.ONESIDED)) then
    collide_type = Tile.TYPE.ONESIDED
  else
    collide_type = Tile.TYPE.WALL
  end
  
  -- check if we're on the ground
  if
    ((not collisiongrid:pixelCollision(self.x, self.y + self.h + 1, collide_type)
    and (not collisiongrid:pixelCollision(self.x + self.w, self.y + self.h + 1, collide_type))))
  then
    self.airborne = true
    self.standingOn = nil
  else
    self.airborne = false
    self.standingOn = collisiongrid:pixelType(self.x, self.y + self.h + 1)
  end
    
  if not self.airborne and self.dy > 0 then
    if collisiongrid:collision(self, collide_type) then
      self:snap_from_collision(0, -1, collisiongrid, math.abs(self.dy), collide_type)
    end
    self.dy = 0
  end 
  
  -- move HORIZONTALLY FIRST
  if self.dx ~= 0 then
    local move_x = self.dx * dt
    local new_x = self.x + move_x
    self.prevx = self.x
    -- is new x in collision ?
    if collisiongrid:collision(self, new_x, self.y) then
      -- move as far as possible towards new position
      self:snap_to_collision(useful.sign(self.dx), 0, 
                        collisiongrid, math.abs(self.dx))
      
      if fisix.BOUNCY then
        self.dx = -self.dx * fisix.BOUNCY 
      else
        self.dx = 0
      end
    else
      -- if not move to new position
      self.x = new_x
    end
  end
  
  -- move the object VERTICALLY SECOND
  if self.dy ~= 0 then
    local move_y = self.dy*dt
    local new_y = self.y + move_y
    self.prevy = self.y
    -- is new y position free ?
    if collisiongrid:collision(self, self.x, new_y) then
      -- if not move as far as possible
      self:snap_to_collision(0, useful.sign(self.dy), collisiongrid, math.abs(self.dy))
      self.dy = 0
    else
      -- if so move to new position
      self.y = new_y
    end
  end
end

function GameObject:draw()
  if DEBUG then
    self.DEBUG_VIEW:draw(self)
  end
end

GameObject.DEBUG_VIEW = 
{
  draw = function(self, target)
    love.graphics.rectangle("line", 
        target.x, target.y, target.w, target.h)
    love.graphics.print(target:typename(), 
        target.x, target.y+32)
  end
}

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return GameObject