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
  
  --horizon = love.graphics.newImage("assets/decors/horizon.png")
  --plan1 = love.graphics.newImage("assets/decors/plan1.png")
  --plan = love.graphics.newImage("assets/decors/plan.png")
  --plan3 = love.graphics.newImage("assets/decors/elem.png")
  
  --baffe= love.audio.newSource("assets/audio/prise_de_degats.ogg", "static")
  --cri_mort = love.audio.newSource("assets/audio/cri_mort.ogg","static")
    
  --image_mort = love.graphics.newImage("assets/images/mort.png")
  
  --explosion = love.audio.newSource("assets/audio/explosion_magique.ogg", "static")
  --jeu_son = love.audio.newSource("assets/audio/themejeu.ogg")
 -- happy = love.audio.newSource("assets/audio/happy.ogg", "static")
  
  im = love.graphics.newImage("assets/hud/spriteVie.png")
  self.gui_life = newAnimation(im, 186, 62, 0.1, 0, 0, 0, {1,2,3,4,5,6,7,8,9})
  self.gui_life:setMode("once")
  self.gui_magic = newAnimation(im, 186, 62, 0.1, 0, 0, 0, {10})
  self.gui_magic:setMode("once")
  
  --jeu_son:play()
  --jeu_son:setLooping(true)
end


function state:enter()

  -- reset objects
  self.player = Player(300, 500) --TODO reset player position based on level
  self.level:load("../assets/maps/map01")
  self.level:addObject(self.player)
  
  -- reset camera
  self.CAMERA_AREA_WIDTH = (love.graphics.getWidth() / 4)
  self.cameraAreaLeft = self.player.x - (self.CAMERA_AREA_WIDTH / 2) 
                              + (love.graphics.getWidth() / 2)
  self.cameraAreaRight = self.player.x + (self.CAMERA_AREA_WIDTH / 2) 
                              + (love.graphics.getWidth() / 2)

end


function state:leave()
	--happy:stop()
end


function state:keypressed(key, uni)
  
  -- exit
  if key=="escape" then
    GameState.switch(title)
    
  -- pause
  elseif key == "p" then
    paused = (not paused)
  end

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

function state:update(dt)
  
  -- do nothing if paused
  if paused then 
    return
  end
  
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
  --[[if self.player:centreX() < self.cameraAreaLeft then
    self.cameraAreaLeft = self.player:centreX()
    self.cameraAreaRight = self.cameraAreaLeft + self.CAMERA_AREA_WIDTH
  elseif self.player:centreX() > self.cameraAreaRight then
    self.cameraAreaRight = self.player:centreX()
    self.cameraAreaLeft = self.cameraAreaRight - self.CAMERA_AREA_WIDTH
  end--]]
  self.camera:lookAt(self.player.x, self.player.y)
  
  -- update GUI
  if self.player.life ~= 0 then
    self.gui_life:seek(((90 - self.player.life)/10) + 1)
    self.gui_magic:seek(((90 - self.player.magic)/10) + 1)
  end
  --self.gui_magic:update(dt)
  --self.gui_life:update(dt)

end


function state:draw()
  local view = {}
  view.x, view.y = self.camera:worldCoords(0, 0)
  view.w, view.h = self.camera:worldCoords(
                          love.graphics.getWidth(), 
                          love.graphics.getHeight())
	

  self.camera:attach()
    --[[for i=0,26 do
      love.graphics.draw(horizon,0+i*(1280),400-((1280-self.camera.y)/40))
      love.graphics.draw(plan1,0+i*(1280),580-((1280-self.camera.y)/40))
      love.graphics.draw(plan,0+i*(1280),580-((1280-self.camera.y)/40))
      love.graphics.draw(plan3,0+i*(1280),580-((1280-self.camera.y)/40))
    end --]]
    self.level:draw(view)
  self.camera:detach()


  -- barre de magie et life :

  --[[
  if self.player.life>0 then
    self.gui_life:draw(100,20)
    self.gui_magic:draw(100,40)
  end

	if self.player.life == 0 then
		draw_scaled(image_mort, 10, 10)
		jeu_son:stop()
		happy:play()
	end
	
  if paused then 
    love.graphics.rectangle("line",700,50, 200,40)
    love.graphics.print("Paused, press 'p' to unpause", 705, 55)
  end
  --]]
end

return state