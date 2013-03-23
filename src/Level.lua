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
local TileGrid = require("TileGrid")
local GameObject = require("GameObject")
local Enemy = require("enemy")
local useful = require("useful")

--[[------------------------------------------------------------
LEVEL CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local Level = Class
{
}

function Level:load(filename)
  local mapfile = require(filename)
  -- load tiles
  self.tilegrid = TileGrid(mapfile)
  
  self.object_types = {}
  -- TODO load objects
  -- FIXME test
  self:addObject(Enemy(350, 250, 128, 128))
end

--[[------------------------------------------------------------
Objects
--]]

function Level:addObject(object)
  -- are there other objects of this type?
  if (not self.object_types[object.type]) then
    self.object_types[object.type] = {}
  end
  table.insert(self.object_types[object.type], object) 
end

--[[------------------------------------------------------------
Game loop
--]]

function Level:update(dt)
  
  -- for each type of object
  for type, objects_of_type in pairs(self.object_types) do
    -- for each object
    useful.map(objects_of_type,
      function(object)
        -- update the object
        object:update(dt, self)
        -- check collisions with other object
        -- ... for each other type of object
        for othertype, objects_of_othertype 
            in pairs(self.object_types) do
          if object:collidesType(othertype) then
            -- ... for each object of this other type
            useful.map(objects_of_othertype,
                function(otherobject)
                  -- check collisions between objects
                  if object:isColliding(otherobject) then
                    object:eventCollision(otherobject)
                  end
                end)
          end
        end  
    end)
  end
end

function Level:draw(view)
  love.graphics.print("I am a Level", 32, 32)
  self.tilegrid:draw(view)
  
  -- for each type of object
  for t, object_type in pairs(self.object_types) do
    -- for each object
    useful.map(object_type,
      function(object)
        -- draw the object
        object:draw()
    end)
  end
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Level