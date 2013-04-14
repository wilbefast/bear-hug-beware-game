--[[
(C) Copyright 2013
William Dyce

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

local Class      = require("hump/class")
local GameObject = require("GameObject")
local useful     = require("useful")

--[[------------------------------------------------------------
GIBLET CLASS
--]]------------------------------------------------------------


local Giblet = Class
{
  type  =  GameObject.TYPE["GIBLET"],
  
  init = function(self, x, y, special_init)
    GameObject.init(self, x, y, 0, 0)
    self.airborne = true
    if special_init then
      special_init(self)
    end
  end,
      
  imScale         = 1,
  rotation        = 0,
  rotation_speed  = 0,
  face            = 1,
  timer           = 30
}
Giblet:include(GameObject)

Giblet.spawn = function (level, x, y, number, special_init)
  for i = 1, number do
    level:addObject(Giblet(x, y, special_init))
  end
end


-- fisix
Giblet.GRAVITY    = 1000
Giblet.FRICTION_X = 10

--[[------------------------------------------------------------
Blood
--]]--

Giblet.blood = function(level, bleeder, amount)
  amount = amount or 5
  Giblet.spawn(level, bleeder.x, bleeder.y, 
      amount + useful.iSignedRand(2), 
      function(gib)
        gib.w, gib.h = 4, 0
        gib.dx = bleeder.dx/3 
                  + useful.signedRand(350)
        gib.dy = bleeder.dy/3 - 300 
                  + useful.signedRand(200)
                  
        if not (bleeder.BLOOD) then
          bleeder = bleeder.source
        end
          
        gib.img = bleeder.BLOOD
        gib.qair = useful.randIn(bleeder.QBLOOD_DROP)
        gib.qground = useful.randIn(bleeder.QBLOOD_PUDDLE)
        gib.imScale = 1 + useful.signedRand(0.7)
      end)
end

--[[------------------------------------------------------------
Corpse
--]]--

Giblet.corpse = function(level, dier)
  
  -- body
  Giblet.spawn(level, dier.x, dier.y, 1, 
      function(gib)
        gib.w, gib.h = 4, 16
        gib.dx = dier.dx / 3
        gib.dy = dier.dy - 200 + useful.signedRand(50)
        gib.face = dier.facing
        gib.img = dier.CORPSE
        gib.qair = dier.QCORPSE_AIR
        gib.qground = dier.QCORPSE_GROUND
        gib.blood_timer = 0
        gib.source = dier
      end)
      
  -- head
  if dier.QCORPSE_HEAD then
    Giblet.spawn(level, dier.x, dier.y, 1, 
      function(gib)
        gib.w, gib.h = 32, 16
        gib.dx = dier.dx / 2
        gib.dy = dier.dy - 200 + useful.signedRand(50)
        gib.face = dier.facing
        gib.img = dier.CORPSE
        gib.qair = dier.QCORPSE_HEAD
        gib.qground = dier.QCORPSE_HEAD
        gib.rotation_speed = useful.sign(dier.dx)*0.15
                          + useful.signedRand(0.05)
        gib.offy = -20
        gib.blood_timer = 0
        gib.source = dier
      end)
  end
end


--[[------------------------------------------------------------
Game loop
--]]

function Giblet:update(dt, level, view)
  -- base update
  GameObject.update(self, dt, level, view)
  
  -- countdown timer
  if (not self.airborne) then
    if (self.timer > 0) then
      local fade_speed = level:countObject(self.type)/10
      if not self:isColliding(view) then
        self.timer = self.timer - 4*dt*fade_speed
      else
        self.timer = self.timer - dt*fade_speed
      end
    else
      self.purge = true
    end
  end
  
  -- rotation
  if self.rotation_speed ~= 0 then
    self.rotation = self.rotation + self.rotation_speed
  end
  
  -- create blood
  if self.blood_timer then
    if self.blood_timer > 0 then
      self.blood_timer = self.blood_timer - dt
    else
      self.blood_timer = 0.3 + useful.signedRand(0.2)
      Giblet.blood(level, self, 1)
    end
  end
    
  -- stop and destroy
  if (not self.airborne) then
    if (self.dx ~= 0) or (self.dy ~= 0) then
      self.dx, self.dy = 0, 0
      if self.rotation_speed ~= 0 then
        self.rotation_speed = 0
      end
    end
  end
end

function Giblet:draw()
  
  -- fade out after a certain amount of time
  if self.timer < 3 then
    love.graphics.setColor(255, 255, 255, 
        math.max(0, 255*self.timer/3))
  end
  
  -- draw depending if on the ground or not
  local quad = useful.tri(self.airborne, self.qair,
      self.qground)
  local offy = (self.offy or 0) + useful.tri(self.airborne, -8, 8)
  local _, _, quadw, quadh = quad:getViewport()
  love.graphics.drawq(self.img, quad,
      self:centreX(), 
      self:centreY() + offy, 
      self.rotation, self.face*self.imScale, self.imScale,
      self.imScale*quadw/2, self.imScale*quadh/2)
  
  love.graphics.setColor(255, 255, 255, 255)
 
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Giblet