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
local Giblet      = require("Giblet")
local Animation   = require("Animation")
local AnimationView = require("AnimationView")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Character = Class
{
  init = function(self, x, y, w, h, 
                  astand, awalk, ajump, apain)
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
  facing      = 1,
  requestMoveX = 0,
  requestMoveY = 0,
  requestJump = false
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
Collisions
--]]

function Character:eventCollision(other, level)
  -- collision with attack
  if (other.type == GameObject.TYPE.ATTACK)
  and (other.launcher.type ~= self.type) then
    push = useful.sign(self:centreX() - other.launcher:centreX())
    if (not other.weapon.DIRECTIONAL) 
    or (push == other.launcher.facing) then
      self.facing = -push
      -- knock-back and -up
      self.dx = push * other.weapon.KNOCKBACK
      self.dy = -other.weapon.KNOCKUP
      -- set stunned
      self:setState(Character.STATE.STUNNED)
      self.timer = other.weapon.STUN_TIME
      -- lose life
      self:addLife(-other.weapon.DAMAGE, level)
      -- let other know that it hasn't missed
      other.n_hit = other.n_hit + 1
      -- play sound
      audio:play_sound(self.SOUND_STUNNED)
      -- create blood
      Giblet.spawn(level, self.x, self.y, 5, 
          self.dx/3, self.dy/3)
    end
  
  -- collision with death
  elseif other.type == GameObject.TYPE.DEATH then
    self:addLife(-math.huge)
  
  -- collision with other characters
  elseif other.type == self.type then
    if (self.state ~= self.STATE.STUNNED)
    and (other.state ~= other.STATE.STUNNED) then
      push = (self:centreX() - other:centreX())
      self.dx = self.dx + push * 3
    end
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

  -- sound effect
  if weapon.SOUND_WARMUP then
    audio:play_sound(weapon.SOUND_WARMUP)
  end
end

function Character:attack(weapon, target)
  -- reload-time and mana-cost
  local reloader = useful.tri(weapon.reloadTime, weapon, self)
  reloader.reloadTime = weapon.RELOAD_TIME
  self:addMagic(-weapon.MANA)
  
  if target then
    -- attack a specific target
    reach = math.min(weapon.REACH, math.abs(target.x - self.x))
  else
    -- spray and pray
    reach = weapon.REACH
  end

  -- create the attack object
  return (Attack(self:centreX() + (reach + self.w)*self.facing,
      self:centreY() + weapon.OFFSET_Y, weapon, self))
end


--[[------------------------------------------------------------
Resources
--]]

function Character:die()
  -- override me!
  self.purge = true
end

function Character:addLife(amount)
  self.life = math.min(100, math.max(0, self.life + amount))
  if self.life == 0 then
    self:die()
  end
end

function Character:addMagic(amount)
  self.magic = math.min(100, math.max(0, self.magic + amount))
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, level)
  
  --[[------
  Timing
  --]]--
  
  -- count-down the generic timer
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
  
  -- count-down the reload timer (if applicable)
  if self.reloadTime and (self.reloadTime > 0) then
    self.reloadTime = self.reloadTime - dt
  end
  
  --[[------
  Control
  --]]--
  
  if self.state == self.STATE.NORMAL then
    -- run
    local moveDir = useful.sign(self.requestMoveX)
    if moveDir ~= 0 then
      self.dx = self.dx + moveDir*self.MOVE_X*dt
      self.facing = moveDir
    end
  
    -- jump
    if self.requestJump then
      -- check if on the ground
      if (not self.airborne) then
        -- boost
        audio:play_sound("jump")
        self.dy = -self.BOOST
      end
    end
  end
  
  --[[------
  Animation Logic
  --]]--
  
  if self.state == self.STATE.NORMAL then
    -- ground-based animations
    if (not self.airborne) and (self.dy == 0) then
      if self.requestMoveX == 0 then
        -- stand
        self.view:setAnimation(self.anim_stand) 
      else
        -- walk
        self.view:setAnimation(self.anim_walk) 
      end
    else
    -- fly
      self.view:setAnimation(self.anim_jump) 
      if self.dy < -500 then
        -- up
        self.view.frame = 1
      elseif self.dy >= 0 then
        -- down
        self.view.frame = 3
      else
        -- apex
        self.view.frame = 2
      end
    end
    
  -- if self.state == self.STATE.NORMAL then
  elseif self.state == self.STATE.WARMUP then
    
    -- back-swing/warmup animation
    if self.deferred_weapon.ANIM_WARMUP then
      self.view:setAnimation(self.deferred_weapon.ANIM_WARMUP)
      self.view:seekPercent(1 - self.timer / self.deferred_weapon.WARMUP_TIME)
    end
    
  -- elseif self.state == self.STATE_WARMUP then
  elseif self.state == self.STATE.STUNNED then
    self.view:setAnimation(self.anim_pain)
    if self.airborne then
      self.view.frame = 1
    else
      self.view.frame = 2
    end
  end
    
  -- animate
  if self.view then
    self.view:update(dt)
  end
  
  --[[------
  Other
  --]]--
  
  -- reset input
  self.requestMoveX, self.requestMoveY = 0, 0
  self.requestJump = false
  
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


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Character