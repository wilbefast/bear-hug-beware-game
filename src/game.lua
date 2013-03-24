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

  self.level         = Level()
  self.camera        = Camera(0, 0)

  self.xLifeBarre  = 150
  self.yLifeBarre  = 100
  self.xMagicBarre = 150
  self.yMagicBarre = 150
  
  fond = love.image.newImageData("assets/decors/horizon.png")
  horizon = love.graphics.newImage(fond)
  plan_1 = love.image.newImageData("assets/decors/plan1.png")
  plan1 = love.graphics.newImage(plan_1)
   
  path = "assets/audio/prise_de_degats.ogg"
  degats_subis = love.audio.newSource(path, "static")
  
  fic="assets/audio/cri_mort.ogg"
  cri_mort = love.audio.newSource(fic,"static")
    
  image_mort = love.graphics.newImage("assets/images/mort.png")
  
  son_explosion = "assets/audio/explosion_magique.ogg"
  explosion = love.audio.newSource(son_explosion,"static")
  
  son_jeu = "assets/audio/themejeu.ogg"
  jeu_son = love.audio.newSource(son_jeu)
  
  happy_tree = "assets/audio/happy.ogg"
  happy = love.audio.newSource(happy_tree,"static")
  
  --jeu_son:play()
  --jeu_son:setLooping(true)
end


function state:enter()
  -- reset objects
  self.player = Player(300, 800)
  self.level:load("../assets/maps/map01")
  self.level:addObject(self.player)
  --TODO reset player position base on level

  self.CAMERA_AREA_WIDTH = (love.graphics.getWidth() / 2)

  self.cameraAreaLeft = self.player.x - (self.CAMERA_AREA_WIDTH / 2) + (love.graphics.getWidth() / 2)
  self.cameraAreaRight = self.player.x + (self.CAMERA_AREA_WIDTH / 2) + (love.graphics.getWidth() / 2)

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

function state:leave()
	happy:stop()
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
  --! TODO remove debug test when no longer needed
  -----------------------------
  elseif key == "m" then
    self.player:life_change(-10)
    self.player:magic_change(-5)
	-- TEST DE SONS :
  elseif key =="f" then
    degats_subis:stop()
    degats_subis:play()
    print("fuck")
  elseif key =="g" then
    cri_mort:play()
  elseif key =="h" then 
	saut:play()
  elseif key == "j" then 
    explosion:play()
  end
-----------------------------
  
  -- player 1 jump
  self.player.requestJump
    = (key == " " or key == "up" 
      or key == "z" or key == "w")
  
  -- player 1 attacks
  self.player.requestLightAttack 
    = (key == "kp0" or key == "y" 
      or key =="rctrl" or key == "lctrl")
  self.player.requestMagicAttack
    = (key == "kp1" or key == "u" 
      or key == "rshift" or key == "lshift")
  
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  if not paused then 
	  -- deal with input
	  local kx, ky = 0, 0
	  if love.keyboard.isDown("left", "q", "a") then
		kx = kx - 1 
	  end
	  if love.keyboard.isDown("right", "d") then
		kx = kx + 1 
	  end
	  if love.keyboard.isDown("up", "z", "w") then
		ky = ky - 1 
	  end
	  if love.keyboard.isDown("down", "s") then 
		ky = ky + 1 
	  end
	  self.player.requestMoveX = kx
	  self.player.requestMoveY = ky

	  -- update the objects in the Level
	  self.level:update(dt)
	  
	  -- point camera at player object
    local hauteur = love.graphics.getHeight() / 2
    local largeur = love.graphics.getWidth() / 2

    local cam_x = self.player:centreX()
    local cam_y = self.player.y

    local levelh = (self.level.tilegrid.h) * self.level.tilegrid.tileh
    local levelw = (self.level.tilegrid.w) * self.level.tilegrid.tilew

    if self.player:centreX() < self.cameraAreaLeft then
      self.cameraAreaLeft = self.player:centreX()
      self.cameraAreaRight = self.cameraAreaLeft + self.CAMERA_AREA_WIDTH
    elseif self.player:centreX() > self.cameraAreaRight then
      self.cameraAreaRight = self.player:centreX()
      self.cameraAreaLeft = self.cameraAreaRight - self.CAMERA_AREA_WIDTH
    end

    if self.player:centreX() <= largeur then
      cam_x = largeur
    end
    if(self.player:centreX() >= levelw - largeur ) then
      cam_x = levelw - largeur
    end

    if self.player.y <= hauteur then
      cam_y = hauteur
    end
    if( self.player.y >= levelh - hauteur ) then
      cam_y = levelh - hauteur
    end

    cam_x = (self.cameraAreaLeft + self.cameraAreaRight) / 2
    self.camera:lookAt( cam_x + self.level.tilegrid.tilew, cam_y + self.level.tilegrid.tileh )
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
    for i=0,26 do
	  love.graphics.draw(horizon,0+i*(1280),400-((1280-self.camera.y)/40))
	  love.graphics.draw(plan1,0+i*(1280),580-((1280-self.camera.y)/40))
    end
    self.level:draw(view)
  self.camera:detach()


  -- barre de magie et life :
  love.graphics.print("life : ",50,100)
  love.graphics.print("magic power : ",50,150)
  love.graphics.rectangle("line",self.xLifeBarre,self.yLifeBarre,100,20)
  love.graphics.rectangle("line",self.xMagicBarre,self.yMagicBarre,100,20)

  love.graphics.rectangle("fill",self.xLifeBarre,self.yLifeBarre,self.player.life,20)
  love.graphics.rectangle("fill",self.xMagicBarre,self.yMagicBarre,self.player.magic,20)

  if self.player.life == 0 then
    love.graphics.print("game over ! ",self.xLifeBarre,self.yLifeBarre)
    love.graphics.rectangle("fill",self.xMagicBarre,self.yMagicBarre,self.player.magic,20)
    love.graphics.rectangle("line",1000, 100,100,100)
    love.graphics.print("game over ! \n t'es mauvais \n JACK",1010,110)
    love.graphics.draw(image_mort, 10, 10)
    jeu_son:setLooping(false)
    jeu_son:stop()
    happy:play()
  end
	
  if paused then 
    love.graphics.rectangle("line",700,50, 200,40)
    love.graphics.print(" Game Paused !! \n Taper \"p\" pour redemarrer. ",705,55)
  end
end

return state