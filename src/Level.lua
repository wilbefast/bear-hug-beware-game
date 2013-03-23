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
  -- load objects
  self.enemies = {}
  -- FIXME test
  table.insert(self.enemies, Enemy(350, 250))
end

--[[------------------------------------------------------------
Game loop
--]]

function Level:update(dt)
  -- update all enemies
  useful.map(self.enemies, 
      function (enemy) enemy:update(dt) end)
end

function Level:draw(view)
  love.graphics.print("I am a Level", 32, 32)
  self.tilegrid:draw(view)
  
  -- draw all enemies
  useful.map(self.enemies, 
      function (enemy) enemy:draw() end)
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Level