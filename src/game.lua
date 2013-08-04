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
local Player = require("Player")


--[[------------------------------------------------------------
CONSTANTS
--]]------------------------------------------------------------

-- camera
local FOLLOW_DIST = 150

-- background images
local SKY
local HORIZON, HORIZON_W, HORIZON_H, QHORIZON 
local MOUNTAINS, MOUNTAINS_W, MOUNTAINS_H, QMOUTAINS
local PORTRAITS, QPORTRAITS
local BARS, QBARS

--[[------------------------------------------------------------
GAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
  
  -- create objects
  self.level = Level()
  self.view = {}
  
  -- set up camera
  self.camera = Camera(0, 0)

  SKY = love.graphics.newImage("assets/background/sky.jpg")
  
  HORIZON = love.graphics.newImage("assets/background/horizon.png")
  HORIZON:setWrap('repeat', 'clamp')
  HORIZON_W, HORIZON_H = HORIZON:getWidth(), HORIZON:getHeight()
  QHORIZON = love.graphics.newQuad(0, 0, DEFAULT_W*3, HORIZON_H, 
                                  HORIZON_W, HORIZON_H)
  
  MOUNTAINS = love.graphics.newImage("assets/background/mountains.png")
  MOUNTAINS:setWrap('repeat', 'clamp')
  MOUNTAINS_W, MOUNTAINS_H = MOUNTAINS:getWidth(), MOUNTAINS:getHeight()
  QMOUNTAINS = love.graphics.newQuad(0, 0, DEFAULT_W*3, MOUNTAINS_H, 
                                  MOUNTAINS_W, MOUNTAINS_H)
  
  PORTRAITS = love.graphics.newImage("assets/hud/portraits.png")
  QPORTRAITS = {}
  for i = 1,3 do
    QPORTRAITS[i] = love.graphics.newQuad((i-1)*64, 0, 64, 64, 
        PORTRAITS:getWidth(), PORTRAITS:getHeight())
  end
  
  BARS = love.graphics.newImage("assets/hud/bars.png")
  QBARS = {}
  for i = 1,3 do
    QBARS[i] = {}
    for j = 1,10 do
      QBARS[i][j] = love.graphics.newQuad(
        0, (i-1)*32, (128/10)*j, 32, 
        BARS:getWidth(), BARS:getHeight()) 
    end
  end
end


function state:enter()

  -- play music
  audio:play_music("music_game")
  
  -- reset objects
  self.player = Player(300, 500) --TODO reset player position based on level
  self.level:load("../assets/maps/map01")
  self.level:addObject(self.player)
  
  -- reset camera
  self.cam_x, self.cam_y = self.player.x, self.player.y
  self.camera:zoomTo(SCALE_MAX)
  self.camera:lookAt(self.cam_x, self.cam_y)

end


function state:leave()
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
  -- calculate what is and isn't in view: useful for culling
  self.view.x, self.view.y = self.camera:worldCoords(0, 0)
  self.view.w, self.view.h = self.camera:worldCoords(
                          love.graphics.getWidth(), 
                          love.graphics.getHeight())
  
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
  self.level:update(dt, self.view)
  
  -- camera follows player horizontally
  if self.player:centreX() < self.cam_x - FOLLOW_DIST then
    self.cam_x = self.player:centreX() + FOLLOW_DIST
  elseif self.player:centreX() > self.cam_x + FOLLOW_DIST then
    self.cam_x = self.player:centreX() - FOLLOW_DIST
  end
  
  -- camera follows player vertically
  self.cam_y = self.player.y
  
  -- don't look outside the level bounds...
  -- ... snap horizontal
  local cam_left  = self.cam_x - DEFAULT_W/2
  local cam_right = cam_left + DEFAULT_W
  if cam_left < 0 then
    self.cam_x = DEFAULT_W/2
  elseif cam_right > self.level.w then
    self.cam_x = self.level.w - DEFAULT_W/2
  end
  -- ... snap vertical
  local cam_top   = self.cam_y - DEFAULT_H/2
  local cam_bottom = cam_top + DEFAULT_H
  if cam_top < 0 then
    self.cam_y = DEFAULT_H/2
  elseif cam_bottom > self.level.h then
    self.cam_y = self.level.h - DEFAULT_H/2
  end
  
  -- update camera
  self.camera:lookAt(self.cam_x, self.cam_y)
  
  -- update listener position
  love.audio.setPosition(self.player.x, self.player.y, 0)
end


function state:draw()
  -- calculate what is and isn't in view: useful for culling
  self.view.x, self.view.y = self.camera:worldCoords(0, 0)
  self.view.w, self.view.h = self.camera:worldCoords(
                          love.graphics.getWidth(), 
                          love.graphics.getHeight())
	
  
  -- draw objects from the camera's point of view
  self.camera:attach()
  
    -- draw the sky
    if self.view.y < 300 then
    love.graphics.setColor(168, 230, 227)
      love.graphics.rectangle("fill", 
          self.view.x, self.view.y, DEFAULT_W, 300 - self.view.y)
    love.graphics.setColor(255, 255, 255)
    end
    love.graphics.draw(SKY, self.view.x, 300)
    
    -- parallax offset
    local base_offset = 
      (math.floor(self.view.x / DEFAULT_W))*DEFAULT_W
  
    -- draw the horizon mountains
    local horizon_offset = 
      base_offset - (self.view.x/20)%DEFAULT_W
    love.graphics.drawq(HORIZON, QHORIZON, horizon_offset, 400)
    love.graphics.setColor(160, 61, 96)
      love.graphics.rectangle("fill", self.view.x, 
          400+HORIZON_H, DEFAULT_W, 400)
    love.graphics.setColor(255, 255, 255)
      
    -- draw the background mountains
    local mountains_offset = 
      base_offset - (self.view.x/10)%DEFAULT_W
    love.graphics.drawq(MOUNTAINS, QMOUNTAINS, mountains_offset, 500)
    love.graphics.setColor(104, 161, 127)
      love.graphics.rectangle("fill", 
          self.view.x, 500+MOUNTAINS_H, DEFAULT_W, 
          self.view.h - (500 + MOUNTAINS_H))
    love.graphics.setColor(255, 255, 255)
    
    -- draw the game objects
    self.level:draw(self.view)

  self.camera:detach()
  
  
  -- GUI
  
  ---!-------------FIXME
  local portrait_i = math.min(#QPORTRAITS, 
      math.floor(#QPORTRAITS * ((100 - self.player.life)/100) + 1))
  self.player.life = self.player.life - 0.5
  ---!-----------FIXME
      
  local portrait_life = math.floor(100/(#QPORTRAITS))
  local next_portrait_
  
  
  
  
  local mod_life = self.player.life % portrait_life
  local hipoints_i = math.floor((#QBARS[1]-1)
      * ((portrait_life - mod_life)/portrait_life) + 1)

  -- draw health-bar
  love.graphics.drawq(BARS, 
      QBARS[portrait_i][hipoints_i], 100, 100)
  
  -- draw portrait
  love.graphics.drawq(PORTRAITS, 
      QPORTRAITS[portrait_i], 100, 100)
 
end

return state