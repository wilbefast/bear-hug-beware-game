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
local GameObject = require("GameObject")
local useful = require("useful")

--[[------------------------------------------------------------
BONUS CLASS
--]]------------------------------------------------------------


local ScorePop = Class
{
	FRICTION_X = 1000,
	FRICTION_Y = 1000,

  init = function(self, x, y, score)
    GameObject.init(self, x, y)
    self.dx = useful.iSignedRand(300) + useful.signedRand()*010
    self.dy = -1500 -math.random()*500
    self.text = "+" .. tostring(score)
    self.life = 1
  end,
      
  type  =  GameObject.TYPE["SCORE"],
}
ScorePop:include(GameObject)

ScorePop.spawn = function (level, x, y, score)
  level:addObject(ScorePop(x, y, score))
end

function ScorePop:draw()
	local a = ((self.life > 0.2) and 255) or (255*self.life/0.2)

	-- print score
  love.graphics.setFont(FONT_LARGE_OUTLINE)
  love.graphics.setColor(32, 16, 32, a)
  love.graphics.printf(self.text, self.x, self.y - 4, 0, "center")
	love.graphics.setColor(255, 128, 255, a)
	love.graphics.setFont(FONT_LARGE)
  love.graphics.printf(self.text, self.x, self.y, 0, "center")
	love.graphics.setColor(255, 255, 255)
	
  -- debug
  love.graphics.setFont(FONT_DEFAULT)
  GameObject.draw(self)
end

function ScorePop:update(dt, level, view)
  GameObject.update(self, dt, level, view)
  
  self.life = self.life - dt
  if self.life < 0 then
  	self.purge = true
  end
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return ScorePop