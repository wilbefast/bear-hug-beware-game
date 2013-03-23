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

local Class = require("hump/class")
local useful = require("useful")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Character = Class{
  init = function(self, x, y, image)
    self.x        = x
    self.y        = y
    self.image    = image
    self.dx       = 0
    self.dy       = 0
  end,
  life  = 100,
  magic = 100,
  speed = 5,
  type  = "character",

  life_change = function(self,nb)
    local newLife = self.life + nb
    if newLife < 0 then
      newLife = 0
    end
    self.life = newLife
  end,

  magic_change = function(self,nb)
    local newMagic = self.magic + nb
    if newMagic < 0 then
      newMagic = 0
    end
    self.magic = newMagic
  end
}

Character.w = 0
Character.h = 0

--[[----------------------------------------------------------------------------
Collisions
--]]

function Character:snap_from_collision(dx, dy, tilegrid, max)
  local i = 0
  while tilegrid:collision(self) and (not max or i < max)  do
    self.x = self.x + dx
    self.y = self.y + dy
    i = i + 1
  end
end

function Character:snap_to_collision(dx, dy, tilegrid, max)
  local i = 0
  while not tilegrid:collision(self, self.x + dx, self.y + dy) 
        and (not max or i < max)  do
    self.x = self.x + dx
    self.y = self.y + dy
    i = i + 1
  end
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, tilegrid)
  
  -- gravity
  if self.GRAVITY and self.airborne then
    self.dy = self.dy + self.GRAVITY
  end
  
  -- check if we're on the ground
  self.airborne = 
    (not tilegrid:pixelCollision(self.x, self.y + self.h + 1))
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

function Character:draw(view)
  image = love.graphics.newImage(self.image)
  love.graphics.draw(image, self.x, self.y)
  
  -- FIXME debug
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

return Character