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
  init = function(self, x, y, w, h, image)
    GameObject.init(self, x, y, w, h)
    self.image = image
  end,

  -- defaults
  state       = 1,
  life        = 100,
  magic       = 100,
  damage      = 0,
  timer       = 0,
  facing      = 1
}
Character:include(GameObject)

--[[------------------------------------------------------------
State machine
--]]

Character.STATE = {}
useful.bind(Character.STATE, "NORMAL", 1)
useful.bind(Character.STATE, "STUNNED", 2)
useful.bind(Character.STATE, "WARMUP", 3)
useful.bind(Character.STATE, "ATTACKING", 4)
useful.bind(Character.STATE, "DYING", 5)
useful.bind(Character.STATE, "DEAD", 6)

function onStateChange(new_state)
  -- override me!
end

function Character:setState(new_state)
  onStateChange(new_state)
  self.state = new_state
end

--[[------------------------------------------------------------
Combat
--]]

function Character:startAttack(weapon, target)
  -- attack will be launched next update
  self.deferred_attack = weapon
  self.deferred_target = target
  self.warmupTime = (weapon.WARMUP_TIME or 0)
end

function Character:attack(weapon)
  -- reload-time and mana-cost
  weapon.reloadTime = weapon.RELOAD_TIME
  self:magic_change(-weapon.MANA)
  -- create the attack object
  return (Attack(
    self:centreX() + weapon.REACH*self.facing ,
    self.y + weapon.OFFSET_Y, weapon, self))
end


--[[------------------------------------------------------------
Resources
--]]

function Character:life_change(amount)
  self.life = math.min(100, math.max(0, self.life + amount))
end

function Character:magic_change(nb)
  self.magic = math.min(100, math.max(0, self.magic + amount))
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, level)
  -- count-down timer
  if self.timer >= 0 then
    self.timer = self.timer - dt
    -- time's up!
    if (self.timer < 0) then
      -- launch the attack when ready
      if self.state == Character.WARMUP then
        level:addObject(self:attack(self.deferred_attack,
                                  self.deferred_target))
        self:setState(Character.ATTACKING)
        
      -- finish stun
      elseif self.state == Character.STUNNED then
        self:setState(Character.NORMAL)
      
      -- finish dying
      elseif self.state == Character.DYING then
        self:setState(Character.DEAD)
      end
    end
  end
  
  -- base update
  GameObject.update(self, dt, level)
end

function Character:draw()
  -- FIXME debug
  love.graphics.print(Character.STATE[self.state], self.x, self.y)
  GameObject.draw(self)
end

return Character