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
local TileGrid = require("TileGrid")

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
  local map = require(filename)
  print(map, map.width, map.height)
  self.tilegrid = TileGrid(map.width, map.height)
end

--[[------------------------------------------------------------
Game loop
--]]

function Level:update(dt)
end

function Level:draw()
    love.graphics.print("I am a Level", 128, 128)
    self.tilegrid:draw()
end

--[[------------------------------------------------------------
EXPORT
--]]

return Level