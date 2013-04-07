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
local ImageGrid = require("ImageGrid")
local GameObject = require("GameObject")
local Enemy = require("Enemy")
local Death = require("Death")
local Bonus = require("Bonus")
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
  -- load lua-parsed "Tiled" map
  local mapfile = require(filename)
  
  -- parse collision grid
  self.tilegrid = TileGrid(mapfile)
  self.w = self.tilegrid.w*self.tilegrid.tilew
  self.h = self.tilegrid.h*self.tilegrid.tileh
  
  -- parse graphics tile grid
  self.imagegrid = ImageGrid(mapfile)
  
  -- parse objects
  self.object_types = {}
  -- ... using this function
  function parse_objects(table, constructor)
    for i, object in ipairs(table.objects) do
      self:addObject(constructor(
        object.x, 
        object.y - 1, 
        object.width, object.height))
    end
  end
  -- ... go through the layers and create objects!
  for z, layer in ipairs(mapfile.layers) do
    if layer.name == "bisounours" then
      parse_objects(layer, Enemy)
    elseif layer.name == "death" then
      parse_objects(layer, Death)
    elseif layer.name == "bonus" then
      parse_objects(layer, Bonus)
    end
  end
end

--[[------------------------------------------------------------
Objects
--]]

function Level:getObject(type, i)
  i = (i or 1)
  local objects = self.object_types[type] 
  if objects and (i <= #objects) then
    return (self.object_types[type][i])
  else
    return nil
  end
end

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
  
  -- update objects
  -- ...for each type of object
  for type, objects_of_type in pairs(self.object_types) do
    -- ...for each object
    useful.map(objects_of_type,
      function(object)
        -- ...update the object
        object:update(dt, self)
        -- ...check collisions with other object
        -- ...... for each other type of object
        for othertype, objects_of_othertype 
            in pairs(self.object_types) do
          if object:collidesType(othertype) then
            -- ...... for each object of this other type
            useful.map(objects_of_othertype,
                function(otherobject)
                  -- check collisions between objects
                  if object:isColliding(otherobject) then
                    object:eventCollision(otherobject, self)
                  end
                end)
          end
        end  
    end)
  end
end

function Level:draw(view)
  --generation fond
    
 
  -- draw the tiles
  self.imagegrid:draw(view)
  --self.tilegrid:draw(view) --FIXME
  
  
  -- for each type of object
  for t, object_type in pairs(self.object_types) do
    -- for each object
    useful.map(object_type,
      function(object)
        -- if the object is in view...
        if object:isColliding(view) then
          -- ...draw the object
          object:draw()
        end
    end)
  end
  
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Level