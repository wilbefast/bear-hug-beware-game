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
  self.player = Player(100, 100)
<<<<<<< HEAD

  self.x_b1 = 600
  self.y_b1 = 150
  self.x_b2 = 600
  self.y_b2 = 200
=======
	paused = false
  x_b1 = 600
  y_b1 = 150
  x_b2 = 600
  y_b2 = 200
>>>>>>> paused
end


function state:enter()
  -- reset objects
  self.level:load("../assets/maps/map01")
  --TODO reset player position base on level
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
  elseif key == "p" then
    if paused then
		paused = false
	else 
		paused = true
	end
  elseif key == "m" then
    self.player:life_change(10,false)
    self.player:magic_change(5,false)
  end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  --FIXME 
  -- move player
  if not paused then 
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
end


function state:draw()
  love.graphics.print("Game screen", 32, 32)
  
  local view = {}
  view.x, view.y = self.camera:worldCoords(0, 0)
  view.w, view.h = self.camera:worldCoords(
                          love.graphics.getWidth(), 
                          love.graphics.getHeight())
  
  self.camera:attach()
  self.level:draw(view)
  self.player:draw(view)
  self.camera:detach()

  -- barre de magie et life :
	love.graphics.print("life : " ,560,150)
	love.graphics.print("magic power : " ,500,200)
	love.graphics.rectangle("line",self.x_b1,self.y_b1,100,20)
	love.graphics.rectangle("line",self.x_b2,self.y_b2,100,20)

	love.graphics.rectangle("fill",self.x_b1,self.y_b1,self.player.life,20)
	if self.player.life == 0 then
<<<<<<< HEAD
		love.graphics.print("game over ! ",self.x_b1,self.y_b1)
	end
	love.graphics.rectangle("fill",self.x_b2,self.y_b2,self.player.magic,20)
=======
		love.graphics.rectangle("line",1000, 100,100,100)
		love.graphics.print("game over ! \n t'es mauvais \n JACK",1010,110)
	end
	love.graphics.rectangle("fill",x_b2,y_b2,self.player.magic,20)
	
	if paused then 
		love.graphics.rectangle("line",50,50, 150,100)
		love.graphics.print(" Game Paused !! ",60,60)
	end

>>>>>>> paused
end

return state