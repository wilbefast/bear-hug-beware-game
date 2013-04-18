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
local SpecialEffect = require("SpecialEffect")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------


local Character = Class
{
  init = function(self, x, y, w, h, 
                  astand, awalk, ajump, apain, adead)
    GameObject.init(self, x, y, w, h)
    -- get animations
    self.anim_stand = astand
    self.anim_walk = awalk
    self.anim_jump = ajump
    self.anim_pain = apain
    self.anim_dead = adead
    -- create view
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

function Character:setState(new_state, timer, level)
  if state ~= new_state then
    self:onStateChange(new_state)
    self.state = new_state
    -- set dead animation on death
    if new_state == self.STATE.DEAD then
      
      -- corpse giblet object?
      if self.CORPSE then
        Giblet.corpse(level, self)
      end
    end
  end
  if timer then
    self.timer = timer
  end
end


--[[------------------------------------------------------------
Collisions
--]]

function Character:eventCollision(other, level)
  
  -- no collisions if dead
  if self.state == self.STATE.DEAD then
    return
  end
  
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
      if self.life <= 0 then
        other.n_kills = other.n_kills + 1
      elseif self.airborne then
        other.n_hit_air = other.n_hit_air + 1
      else
        other.n_hit = other.n_hit + 1
      end

      -- play sound
      audio:play_sound(self.SOUND_STUNNED, 0.1, self.x, self.y)
      -- create blood
      if self.BLOOD then
        Giblet.blood(level, self, other.weapon.DAMAGE/10)
      end
      -- other special logic
      if self.onAttacked then
        self:onAttacked(other, level)
      end
    end
  
  -- collision with death
  elseif other.type == GameObject.TYPE.DEATH then
    self:addLife(-math.huge, level)
  
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

function Character:startAttack(weapon, target, level, view)
  -- attack queued to be launched when warmup is over
  self.deferred_weapon = weapon
  self.deferred_target = target
  self:setState(Character.STATE.WARMUP, (weapon.WARMUP_TIME or 0))

  -- mana-cost is deducted when warmup starts
  self:addMagic(-weapon.MANA)
  
  -- WARMUP sound effect
  if weapon.SOUND_WARMUP then
    audio:play_sound(weapon.SOUND_WARMUP, 0.2, self.x, self.y)
  end
  
  -- WARMUP visual special-effect
  if weapon.SFX_WARMUP then
    level:addObject(SpecialEffect(self:centreX(), self:centreY(),
        weapon.SFX_WARMUP, weapon.SFX_WARMUP.n_frames/weapon.WARMUP_TIME))
  end
end

function Character:attack(weapon, target, level, view)
  -- reload-time
  local reloader = useful.tri(weapon.reloadTime, weapon, self)
  reloader.reloadTime = weapon.RELOAD_TIME
  
  local reach = weapon.REACH + self.w/2
  if target then
    -- attack a specific target
    reach = math.min(reach, math.abs(target.x - self.x))
  end
  
  -- ATTACK visual special-effect
  if weapon.SFX_LAUNCH then
    level:addObject(SpecialEffect(self:centreX(), self:centreY(),
        weapon.SFX_LAUNCH, weapon.SFX_LAUNCH.n_frames/weapon.DURATION))
  end
    
  -- create the attack object
  level:addObject(Attack(self:centreX() + reach*self.facing,
      self:centreY() + weapon.OFFSET_Y, weapon, self))
end


--[[------------------------------------------------------------
Resources
--]]

function Character:die()
  -- override me!
  self.purge = true
end

function Character:addLife(amount, level)
  self.life = math.min(100, math.max(0, self.life + amount))
  if self.life == 0 then
    self:setState(self.STATE.DEAD, nil, level)
    self:die()
  end
end

function Character:addMagic(amount)
  self.magic = math.min(100, math.max(0, self.magic + amount))
end

--[[------------------------------------------------------------
Game loop
--]]

function Character:update(dt, level, view)
  
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
        self:attack(self.deferred_weapon, self.deferred_target, level, view)    
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
        audio:play_sound("jump", 0.2, self.x, self.y)
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
    
    
  -- if not self.state == self.STATE.NORMAL then
  elseif self.state == self.STATE.DEAD then
    -- corpse animation?
    if self.anim_dead then
      if self.airborne then
        self.view:setAnimation(self.anim_pain)
        self.view.frame = 1
      else
        self.view:setAnimation(self.anim_dead)
      end
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
  end
  
  if DEBUG then
    love.graphics.print(Character.STATE[self.state], self.x, self.y)
    GameObject.draw(self)
  end 
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Character