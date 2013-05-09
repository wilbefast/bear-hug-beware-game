--[[
(C) Copyright 2013 William Dyce

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
local GameObject = require("GameObject")
local useful = require("useful")

--[[------------------------------------------------------------
DOODAD CLASS
--]]------------------------------------------------------------

local TREES = 
  love.graphics.newImage("assets/background/trees.png")
  
local QTREES =
{ 
  love.graphics.newQuad(0, 0, 340, 512, 1024, 512),
  love.graphics.newQuad(340, 0, 340, 512, 1024, 512),
  love.graphics.newQuad(640, 0, 340, 512, 1024, 512)
}
  
local GRASS = 
  love.graphics.newImage("assets/background/grass.png")
local QBUSH =
{
  love.graphics.newQuad(0, 128, 256, 128, 256, 256)
}
local QGRASS = 
{
  love.graphics.newQuad(0, 0, 128, 128, 256, 256),
  love.graphics.newQuad(128, 0, 128, 128, 256, 256)
}

--[[------------------------------------------------------------
Initialisation
--]]--

local Doodad = Class
{
  type  =  GameObject.TYPE["DOODAD"],
      
  init = function(self, x, y, w, h, img, quads)
    GameObject.init(self, x - w/2, y - h + 16, w, h)
    self.image = img
    self.quad = useful.randIn(quads)
  end,
}
Doodad:include(GameObject)
  

function Doodad.tree(x, y)
  return Doodad(x, y, 340, 512, TREES, QTREES)
end

function Doodad.grass(x, y)
  return Doodad(x, y, 128, 128, GRASS, QGRASS)
end

function Doodad.bush(x, y)
  return Doodad(x, y, 256, 128, GRASS, QBUSH)
end

--[[------------------------------------------------------------
Game loop
--]]--

function Doodad:draw()
  
  love.graphics.drawq(self.image, self.quad, self.x, self.y, 
      0, 1, 1, 0, 0)
  
  if DEBUG then
    GameObject.draw(self)
  end 
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Doodad