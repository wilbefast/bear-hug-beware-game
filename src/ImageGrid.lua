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
IMAGEGRID CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local ImageGrid = Class
{
  init = function(self, mapfile)
  
    -- grab the size of the tiles
    self.quadw = mapfile.tilewidth
    self.quadh = mapfile.tileheight
  
    -- grab the size of the map
    self.w = mapfile.width
    self.h = mapfile.height
    
    -- grab the tilesets
    self.tilesets = {}
    for t, tileset in ipairs(mapfile.tilesets) do
      local new_tset = 
      {
        image = love.graphics.newImage(tileset.image),
        n_across = math.floor(tileset.imagewidth 
                              / tileset.tilewidth),
        n_down = math.floor(tileset.imageheight 
                              / tileset.tileheight),
        
        quads = {}
        
      }
      --[[for x = 1, self.w do
        self.quads[x] = {}
        for y = 1, self.h do
          self.quads[x][y] = love.graphics.newQuad(x*self.quadw, y*self.quadh,
                                                    self.quadw, self.quadh)
        end
      end--]]
      
      -- save the parsed tileset
      table.insert(self.tilesets, new_tset)
    end

    -- for each layer
    for _, layer in ipairs(mapfile.layers) do
      
      --! GENERATE IMAGE GRID
      if layer.type == "tilelayer" then
      end
    end
    
    --[[
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
    --]]
  end
}

--[[------------------------------------------------------------
Game Loop
--]]

function ImageGrid:draw(view)
  local start_x = math.max(1, 
              math.floor(view.x / self.quadw))
  local end_x = math.min(self.w, 
              start_x + math.ceil(view.w / self.quadw))
  
  local start_y = math.max(1, 
              math.floor(view.y / self.quadh))
  local end_y = math.min(self.h, 
              start_y + math.ceil(view.h / self.quadh))
  
  for x = start_x, end_x do
    for y = start_y, end_y do
    end
  end

    --TODO use sprite batches
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return ImageGrid