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
local Tile = require("Tile")
local useful = require("useful")

--[[------------------------------------------------------------
TILEGRID CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local TileGrid = Class
{
  init = function(self, mapfile)
  
    -- grab the size of the map
    self.w = mapfile.width
    self.h = mapfile.height
    
    -- grab the size of the tiles
    self.tilew = mapfile.tilewidth
    self.tileh = mapfile.tileheight
    
    -- grab the tileset
    self.tilesets = {}
    for t, tileset in ipairs(mapfile.tilesets) do
      self.tilesets[tileset.firstgid] = 
      {
        image = love.graphics.newImage(tileset.image)
      }
    end
    
    -- create each layer
    self.layers = {}
    for z, layer in ipairs(mapfile.layers) do
      if layer.type == "tilelayer" then

        -- the mapfile stores tiles in [row, col] format
        local temp_layer = {}
        local data_i = 1
        for row = 1, self.h do
          temp_layer[row] = {}
          for col = 1, self.w do
            temp_layer[row][col] = Tile(layer.data[data_i])
            data_i = data_i + 1
          end
        end
          
        -- we want them in [x, y] format, so we transpose
        self.layers[z] = {}
        for x = 1, self.w do
          self.layers[z][x] = {}
          for y = 1, self.h do
            self.layers[z][x][y] = temp_layer[y][x]
          end
        end
      end
    end
  end
}

--[[------------------------------------------------------------
Game loop
--]]

function TileGrid:draw(view)
  
  local start_x = math.max(1, 
              math.floor(view.x / self.tilew))
  local end_x = math.min(self.w, 
              start_x + math.ceil(view.w / self.tilew))
  
  local start_y = math.max(1, 
              math.floor(view.y / self.tileh))
  local end_y = math.min(self.h, 
              start_y + math.ceil(view.h / self.tileh))
  
  for i = 1, #self.layers do
    if( self.layers[i].type =="tilelayer") then
      for x = start_x, end_x do
        for y = start_y, end_y do
          local tset_i = self.layers[1][x][y].type
          if tset_i ~= 0 then
            local img = self.tilesets[tset_i].image
            love.graphics.draw(img, x * self.tilew, 
                                    y * self.tileh)
          end
        end
      end
    end
  end

    --TODO use sprite batches
end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function TileGrid:gridToTile(x, y, z)
  z = (z or 1)
  if self:validGridPos(x, y, z) then
    return self.layers[z][x][y]
  else
    return nil --FIXME
  end
end

function TileGrid:pixelToTile(x, y, z)
  return self:gridToTile(math.floor(x / self.tilew),
                         math.floor(y / self.tileh), z)
end

--[[----------------------------------------------------------------------------
Avoid array out-of-bounds exceptions
--]]--


function TileGrid:validGridPos(x, y)
  return (x >= 1 
      and y >= 1
      and x <= self.w 
      and y <= self.h) 
end

function TileGrid:validPixelPos(x, y)
  return (x >= 0
      and y >= 0
      and x <= self.size.x*self.tilew
      and y <= self.size.y*self.tileh)
end


--[[----------------------------------------------------------------------------
Basic collision tests
--]]--

function TileGrid:gridCollision(x, y, type)
  type = (type or Tile.TYPE.WALL)
  return (self:gridToTile(x, y).type == type)
end

function TileGrid:pixelCollision(x, y, type)
  type = (type or Tile.TYPE.WALL)
  local tile = self:pixelToTile(x, y)
  return ((not tile) or ((tile.type > 0) 
                        and (tile.type <= type)))
end

--[[----------------------------------------------------------------------------
GameObject collision tests
--]]--

function TileGrid:collision(go, x, y, type)
  -- x & y are optional: leave them out to test the object where it actually is
  x = (x or go.x)
  y = (y or go.y)
  
  -- rectangle collision mask, origin is at the top-left
  return (self:pixelCollision(x,         y,        type) 
      or  self:pixelCollision(x + go.w,  y,         type) 
      or  self:pixelCollision(x,         y + go.h,  type)
      or  self:pixelCollision(x + go.w,  y + go.h, type))
end

function TileGrid:collision_next(go, dt)
  return self:collision(go, go.x + go.dx*dt, go.y + go.dy*dt)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return TileGrid