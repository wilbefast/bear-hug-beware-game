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

local Class      = require("hump/class")
local GameObject = require("GameObject")
local useful      = require("useful")
local Attack      = require("Attack")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Character = Class
{
  init = function(self, x, y, w, h, imagefile)
    GameObject.init(self, x, y, w, h)
    self.image     = love.graphics.newImage(imagefile)
  end,

  life       = 100,
  magic      = 100,
  damage     = 0,
  warmupTime = 0,
  reloadTime = 0,
  stunnedTime = 0,
  facing     = 1
}
Character:include(GameObject)


--[[------------------------------------------------------------
Combat
--]]

function Character:startAttack(weapon, target)
  
  self.deferred_attack = weapon
  self.deferred_target = target
  self.warmupTime = useful.tri(weapon.WARMUP_TIME > 0, 
                              weapon.WARMUP_TIME, 0.01)
  
end

function Character:attack(weapon)
  weapon.reloadTime = weapon.RELOAD_TIME

  self:magic_change(-weapon.MANA)

  return (Attack(
    self.x + self.w/2 + weapon.REACH*self.facing ,
    self.y + weapon.OFFSET_Y, weapon, self))
end


--[[------------------------------------------------------------
Resources
--]]

function Character:life_change(nb)
  local newLife = self.life + nb
  if newLife <= 0 then
    newLife = 0
  end
  self.life = newLife
end

function Character:magic_change(nb)
  local newMagic = self.magic + nb
  if newMagic <= 0 then
    newMagic = 0
  end
  if newMagic > self.MAXMANA then
    newMagic = self.MAXMANA
  end

  self.magic = newMagic
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, level)
  -- warm-up attack
  if self.warmupTime > 0 then
    self.warmupTime = self.warmupTime - dt
    if (self.warmupTime <= 0) and self.deferred_attack then
      level:addObject(self:attack(self.deferred_attack,
                                  self.deferred_target))
    end
  end
  
  -- reload weapon
  if self.reloadTime > 0 then
    self.reloadTime = self.reloadTime - dt
  end
  
  -- recover from stun
  if self.stunnedTime > 0 then
    self.stunnedTime = self.stunnedTime - dt
  end
  
  -- base update
  GameObject.update(self, dt, level)
end

function Character:draw()
  -- FIXME animation
  love.graphics.draw(self.image, self.x, self.y)
  love.graphics.print(self.life, self.x, self.y)
  -- FIXME debug
  GameObject.draw(self)
end

return Character