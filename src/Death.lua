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

--[[------------------------------------------------------------
DEATH CLASS
--]]------------------------------------------------------------


local Death = Class
{
  init = function(self, x, y, w, h)
    GameObject.init(self, x, y, w, h)
  end,
      
  type  =  GameObject.TYPE["DEATH"],
}
Death:include(GameObject)

function Death:draw()
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Death