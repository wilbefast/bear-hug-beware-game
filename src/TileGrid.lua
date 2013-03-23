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
    self.width = mapfile.width
    self.height = mapfile.height
    
    -- grab the size of the tiles
    self.tilewidth = mapfile.tilewidth
    self.tileheight = mapfile.tileheight
    
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
        for row = 1, self.height do
          temp_layer[row] = {}
          for col = 1, self.width do
            temp_layer[row][col] = Tile(layer.data[data_i])
            data_i = data_i + 1
          end
        end
          
        -- we want them in [x, y] format, so we transpose
        self.layers[z] = {}
        for x = 1, self.width do
          self.layers[z][x] = {}
          for y = 1, self.height do
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
              math.floor(view.x / self.tilewidth))
  local end_x = math.min(self.width, 
              start_x + math.ceil(view.w / self.tilewidth))
  
  local start_y = math.max(1, 
              math.floor(view.y / self.tileheight))
  local end_y = math.min(self.height, 
              start_y + math.ceil(view.h / self.tileheight))
    
  for x = start_x, end_x do
    for y = start_y, end_y do
      local tset_i = self.layers[1][x][y].type
      if tset_i ~= 0 then
        local img = self.tilesets[tset_i].image
        love.graphics.draw(img, x * self.tilewidth, 
                                y * self.tileheight)
      end
    end
  end

    --TODO use sprite batches
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return TileGrid