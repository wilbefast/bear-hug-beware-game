--[[
(C) Copyright 2013 
William Dyce, Maxime Ailloud, Alex verbrugghe, Julien Deville

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


local Level = require("Level")
local Camera = require("hump/camera")
local Player = require("player")

--[[------------------------------------------------------------
GAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
  -- create objects
  self.level = Level()
  self.camera = Camera(0, 0)
  self.player = Player()
end


function state:enter()
  -- reset objects
  self.level:load("../assets/maps/map01")
  self.camera:lookAt(128, 128) --FIXME look at player

  --TODO reset player position base on level
  self.player.x, self.player.y, self.player.image = 100, 100, "assets/sprites/mur.png"
  self.camera:lookAt(self.player.x, self.player.y)
end


function state:focus()
end


function state:mousepressed(x, y, btn)

end


function state:mousereleased(x, y, btn)
  
end


function state:joystickpressed(joystick, button)
  
end


function state:joystickreleased(joystick, button)
  
end


function state:quit()
  
end


function state:keypressed(key, uni)
  if key=="escape" then
    GameState.switch(title)
  end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  --FIXME 
  -- move player
  if love.keyboard.isDown("left") then
    self.player.x = self.player.x - dt*512
  end
  if love.keyboard.isDown("right") then
    self.player.x = self.player.x + dt*512
  end
  if love.keyboard.isDown("down") then
    self.player.y = self.player.y + dt*512
  end
  if love.keyboard.isDown("up") then
    self.player.y = self.player.y - dt*512
  end
  -- point camera at player
  self.camera:lookAt(self.player.x, self.player.y)
end


function state:draw()
  love.graphics.print("Game screen", 32, 32)


  self.camera:attach()
  self.level:draw()
  self.player:draw()
  self.camera:detach()

--[[
  level:draw()
  player.draw()

  love.graphics.rectangle("line",50,50,600,500)
  love.graphics.rectangle("fill",c1.x,c1.y,c1.tw,c1.th)
  love.graphics.rectangle("fill",c2.x,c2.y,c2.tw,c2.th)
  love.graphics.rectangle("fill",c3.x,c3.y,c3.tw,c3.th)
  love.graphics.rectangle("fill",player.x,player.y,5,5)
--]]

end

return state