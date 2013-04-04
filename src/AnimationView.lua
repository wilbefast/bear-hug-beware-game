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

--[[------------------------------------------------------------
ANIMATIONVIEW CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local AnimationView = Class
{
  init = function(self, anim, speed, frame)
    self.anim = anim
    self.speed = (speed or 0.0)
    self.frame = (frame or math.random(self.anim.n_frames))
  end,
}
  
  
--[[------------------------------------------------------------
Game loop
--]]
    
function AnimationView:draw(object)
  self.anim:draw(object.x, object.y, self.frame, 
                  self.flip_x, self.flip_y, object.w, self.offy)
end

function AnimationView:update(dt)
  self.frame = self.frame + self.speed*dt
  if self.frame > self.anim.n_frames then
    self.frame = self.frame - self.anim.n_frames + 1
    return true -- animation end
  end
  if self.frame < 1 then
    self.frame = self.frame + self.anim.n_frames - 1
    return true -- animation end
  end
  return false -- animation continues
end

--[[------------------------------------------------------------
Mutators
--]]

function AnimationView:randomSubimage()
  self.subimage = math.rand()
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return AnimationView