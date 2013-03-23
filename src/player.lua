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
  magie = 100,
  init = function(self, x, y, image)
    Character.init(self, x, y, image)
  end,
  life = function(self,nb,bool)
	if bool then 
		self.life = self.life + 1
	else
		self.life = self.life - 1
	end
  end,
  
  magic = function(self,nb,bool)
	if bool then 
		self.magie = self.magie + 1
	else
		self.magie = self.magie - 1
	end
  end
}

Player:include(Character)

return Player