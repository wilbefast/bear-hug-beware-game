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

local Character = require("character")
local Class = require("hump/class")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Player = Class
  {
  type  = "player",
  magic = 100,
  init = function(self, x, y, image)
    Character.init(self, x, y, image)
  end,
  life_change = function(self,nb,add)
	if add then 
		if self.life+nb < 100 then
			self.life = self.life + nb
		end
	else
		if self.life-nb>=0 then
			self.life = self.life - nb
		end
	end
  end,
  
  magic_change = function(self,nb,add)
	love.graphics.print("value : "..self.magic,400,400)
	if add then 
		if self.magic+nb<100 then
			self.magic = self.magic + nb
		end
	else
		if self.magic-nb >= 0 then 
			self.magic = self.magic - nb
		end
	end	
  end
}

Player:include(Character)

return Player