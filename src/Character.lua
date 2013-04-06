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
local Animation   = require("Animation")
local AnimationView = require("AnimationView")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Character = Class
{
  init = function(self, x, y, w, h, astand, awalk, ajump, apain)
    GameObject.init(self, x, y, w, h)
    -- get animations
    self.anim_stand = astand
    self.anim_walk = awalk
    self.anim_jump = ajump
    self.anim_pain = apain
    -- creat view
    self.view = AnimationView(self.anim_stand)
    self.view.offy = -7
    self.view.speed = 6
  end,

  -- defaults
  state       = 1,
  life        = 100,
  magic       = 100,
  damage      = 0,
  timer       = -1,
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

function Character:onStateChange(new_state)
  -- override me!
end

function Character:setState(new_state, timer)
  if state ~= new_state then
    self:onStateChange(new_state)
    self.state = new_state
  end
  if timer then
    self.timer = timer
  end
end

--[[------------------------------------------------------------
Combat
--]]

function Character:startAttack(weapon, target)
  -- attack will be launched next update
  self.deferred_weapon = weapon
  self.deferred_target = target
  self:setState(Character.STATE.WARMUP, (weapon.WARMUP_TIME or 0))
  
  -- start the back-swing/warmup animation
  if weapon.ANIM_WARMUP then
    self.view:setAnimation(weapon.ANIM_WARMUP)
  end
end

function Character:attack(weapon)
  -- reload-time and mana-cost
  weapon.reloadTime = weapon.RELOAD_TIME
  self:addMagic(-weapon.MANA)
  -- create the attack object
  return (Attack(
    self:centreX() + weapon.REACH*self.facing ,
    self.y + weapon.OFFSET_Y, weapon, self))
end


--[[------------------------------------------------------------
Resources
--]]

function Character:addLife(amount)
  self.life = math.min(100, math.max(0, self.life + amount))
end

function Character:addMagic(amount)
  self.magic = math.min(100, math.max(0, self.magic + amount))
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, level)
  
  -- count-down timer
  if self.timer > 0 then
    self.timer = self.timer - dt
    -- time's up!
    if (self.timer < 0) then
      -- launch the attack when ready
      if self.state == Character.STATE.WARMUP then
        level:addObject(self:attack(self.deferred_weapon, self.deferred_target))      
        self:setState(Character.STATE.ATTACKING, self.deferred_weapon.DURATION)
        
      -- finish attack
      elseif self.state == Character.STATE.ATTACKING then
        self:setState(Character.STATE.NORMAL)
        
      -- finish stun
      elseif self.state == Character.STATE.STUNNED then
        self:setState(Character.STATE.NORMAL)
      
      -- finish dying
      elseif self.state == Character.STATE.DYING then
        self:setState(Character.STATE.DEAD)
      end
    end
  end
  
  -- animate
  if self.view then
    self.view:update(dt)
  end
  
  -- base update
  GameObject.update(self, dt, level)
end

function Character:draw()
  if self.view then
    self.view.flip_x = (self.facing < 0)
    self.view:draw(self)
  else
    -- FIXME debug view
    love.graphics.print(Character.STATE[self.state], self.x, self.y)
    love.graphics.print(self.timer, self.x + 64, self.y)
    GameObject.draw(self)
  end
end

return Character