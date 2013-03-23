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

--[[------------------------------------------------------------
TILEGRID CLASS
--]]------------------------------------------------------------


local TileGrid = Class
{
  init = function(self, mapfile)
    self.width = mapfile.width
    self.height = mapfile.height
  end
}

function TileGrid:draw()
    love.graphics.print("I am a TileGrid", 256, 256)
    love.graphics.print(self.width, 256, 300)
    love.graphics.print(self.height, 300, 300)
end

return TileGrid