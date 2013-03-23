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
local Class     = require("hump/class")

--[[------------------------------------------------------------
CHARACTER CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialise
--]]

local Player = Class
{
  type  = "player",
  magic = 100,

  init = function(self, x, y)
    Character.init(self, x, y, "assets/sprites/mur.png")
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

--[[------------------------------------------------------------
Constants
--]]

Player.SPEED_X = 8
Player.SPEED_Y = 8

--[[------------------------------------------------------------
Game loop
--]]

function Player:update(dt)

  -- TODO check if move is possible (stunned?)
  -- accelerate
  self.dx = self.requestMoveX * self.SPEED_X
  self.dy = self.requestMoveY * self.SPEED_Y
  
  -- attack
  if self.requestLightAttack then
    print("request light attack")
    -- TODO
    
    -- reset
    self.requestLightAttack = false
  end
  
  if self.requestHeavyAttack then
    print("request heavy attack")
    -- TODO
    
    -- reset
    self.requestHeavyAttack = false
  end

  if self.requestMagicAttack then
    print("request magic attack")
    -- TODO
    
    -- reset
    self.requestMagicAttack = false
  end
  
  -- reset input requests to false
  self.requestMoveX, self.requestMoveY = 0, 0

  -- base update
  Character.update(self, dt)
end


return Player