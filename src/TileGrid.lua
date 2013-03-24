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
  
    -- grab the size of the tiles
    self.tilew = mapfile.tilewidth
    self.tileh = mapfile.tileheight
  
    -- grab the size of the map
    self.w = mapfile.width
    self.h = mapfile.height
    
    -- create the collision map
    self.tiles = {}
    for x = 1, self.w do
      self.tiles[x] = {}
      for y = 1, self.h do
        self.tiles[x][y] = Tile()
      end
    end
    
    -- for each layer
    for _, layer in ipairs(mapfile.layers) do
      
      --! GENERATE *COLLISION* GRID
      if layer.type == "objectgroup" then
        local type
        if layer.name == "murs" then
          type = Tile.TYPE.WALL
        elseif layer.name == "plateformes" then
          type = Tile.TYPE.ONESIDED
        end
      
        if type then
          function setType(tile) 
            if (tile.type == Tile.TYPE.EMPTY) or (tile.type > type) then
              tile.type = type
            end
          end
          for i, object in ipairs(layer.objects) do
            local x, y = self:pixelToGrid(object.x, object.y)
            local w, h = self:pixelToGrid(object.width, 
                                          object.height)
            self:mapRectangle(x, y, w, h, setType)
          end
        end
      end
    end
  end
}


--[[----------------------------------------------------------------------------
Map functions to all or part of the grid
--]]--

function TileGrid:mapRectangle(startx, starty, w, h, f)
  for x = startx, startx + w do
    for y = starty, starty + h do
      if self:validGridPos(x, y) then
        f(self.tiles[x][y])
      end
    end
  end
end

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
  
  for x = start_x, end_x do
    for y = start_y, end_y do
      local type = self.tiles[x][y].type
      if type > 1 then
        
        
        if type == 2 then
          love.graphics.setColor(0,0,255)
        end
        
        love.graphics.rectangle("line", x*self.tilew,
            y*self.tileh, self.tilew, self.tileh)

        --local img = self.tilesets[tset_i].image
        --love.graphics.draw(img, x * self.tilew, 
          --                      y * self.tileh)
        
        love.graphics.setColor(255,255,255)
      end
    end
  end

    --TODO use sprite batches
end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function TileGrid:gridToTile(x, y, z)
  if self:validGridPos(x, y, z) then
    return self.tiles[x][y]
  else
    return nil --FIXME
  end
end

function TileGrid:pixelToTile(x, y, z)
  return self:gridToTile(math.floor(x / self.tilew),
                         math.floor(y / self.tileh), z)
end


--[[----------------------------------------------------------------------------
Conversion
--]]--

function TileGrid:pixelToGrid(x, y)
  return math.floor(x / self.tilew), math.floor(y / self.tileh)
end

function TileGrid:gridToPixel(x, y)
  return x * self.tilew, y * self.tileh
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
  return ((not tile) or ((tile.type > 1) 
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