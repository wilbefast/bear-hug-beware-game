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
    -- create each layer
    self.layers = {}
    for z, layer in ipairs(mapfile.layers) do
      if layer.type == "tilelayer" then
        self.layers[z] = {}
        local data_i = 1
        for y = 1, self.height do
          self.layers[z][y] = {}
          for x = 1, self.width do
            self.layers[z][y][x] = Tile(layer.data[data_i])
            data_i = data_i + 1
          end
        end
      end
    end
  end
}

--[[------------------------------------------------------------
Game loop
--]]

function TileGrid:draw()
    for x = 1, self.width do
      for y = 1, self.height do
        print(x, y, self.layers[1][y][x].type)
        love.graphics.rectangle(
          useful.tri(self.layers[1][y][x].type == 0, "line", "fill"), 
            x*self.tilewidth, y*self.tileheight,
            self.tilewidth, self.tileheight)
  
      end
    end
    
    --TODO use sprite batches
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return TileGrid