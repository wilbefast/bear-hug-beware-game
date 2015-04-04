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
local GameObject = require("GameObject")
local Player = require("Player")
local Enemy = require("Enemy")
local useful = require("useful")


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
local BAR_DIVISIONS = 30
local DEFEAT_SPLASH

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
    QPORTRAITS[i] = love.graphics.newQuad((i-1)*72, 0, 72, 92, 
        PORTRAITS:getWidth(), PORTRAITS:getHeight())
  end
  
  BARS = love.graphics.newImage("assets/hud/bars.png")
  QBARS = {}
  for i = 1,4 do
    QBARS[i] = {}
    for j = 1,BAR_DIVISIONS do
      QBARS[i][j] = love.graphics.newQuad(
        0, (i-1)*48, (160/BAR_DIVISIONS)*j, 48, 
        BARS:getWidth(), BARS:getHeight()) 
    end
  end
  QBARS[5] = love.graphics.newQuad(
        0, 192, 160, 48, 
        BARS:getWidth(), BARS:getHeight()) 
  
  DEFEAT_SPLASH = love.graphics.newImage("assets/hud/dead_fr.png")
end

function state:recalculate_view()
  -- calculate what is and isn't in view: useful for culling
  self.view.x, self.view.y = self.camera:worldCoords(0, 0)
  
  self.view.endx, self.view.endy = self.camera:worldCoords(
    love.graphics.getWidth() + self.level.collisiongrid.tilew, 
    love.graphics.getHeight() + self.level.collisiongrid.tileh)
    
  self.view.w, self.view.h = self.view.endx - self.view.x,
                             self.view.endy - self.view.y
end

function state:enter()

  -- play music
  audio:play_music("music_game")
  
  -- reset objects
  self.level:load("../assets/maps/arena")
  self.player = self.level:getObject(GameObject.TYPE.PLAYER)
  
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
    love.event.push("quit")
    
  -- pause
  elseif key == "p" then
    paused = (not paused)
  
  -- restart after death
  elseif key=="return" or key=="kpenter" then
    if self.player.state == self.player.STATE.DEAD then
      GameState.switch(self)
    end
  end
 
  -- player 1 jump
  self.player.requestStartJump
    = (key == " " or key == "up" 
      or key == "z" or key == "w")
  
  -- player 1 attacks
  self.player.requestStartLightAttack 
    = (key == "kp0" or key == "y" 
      or key =="rctrl" or key == "lctrl")
  self.player.requestStartMagicAttack
    = (key == "kp1" or key == "u" 
      or key == "rshift" or key == "lshift")
  
end

function state:keyreleased(key, uni)
  -- player 1 jump
  if (key == " " or key == "up" 
      or key == "z" or key == "w") then
    self.player.requestJump = true
    self.player.requestStartJump = false
  end
  
  -- player 1 attacks
  self.player.requestLightAttack 
    = (key == "kp0" or key == "y" 
      or key =="rctrl" or key == "lctrl")
  self.player.requestMagicAttack
    = (key == "kp1" or key == "u" 
      or key == "rshift" or key == "lshift")
end

local _joystick = nil

function state:joystickpressed( joystick, button )
	_joystick = joystick
  -- player 1 jump
  self.player.requestStartJump = (button == 1)
  self.player.requestStartLightAttack = (button == 3)
  self.player.requestStartMagicAttack = (button == 4)
end

function state:joystickreleased( joystick, button )
	_joystick = joystick
	if button == 1 then
    self.player.requestJump = true
    self.player.requestStartJump = false
  end
  self.player.requestLightAttack = (button == 3)
  self.player.requestMagicAttack = (button == 4)
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

  if _joystick then
  	local jx, jy = _joystick:getGamepadAxis("leftx"), _joystick:getGamepadAxis("lefty")
  	if (math.abs(jx) < 0.3) and (math.abs(jy) < 0.3) then
  		jx, jy = 0, 0
  	end
  	kx, ky = kx + jx, ky + jy

  	if _joystick:isGamepadDown("dpleft") then 
  		kx = kx - 1
  	end
		if _joystick:isGamepadDown("dpleft") then 
  		kx = kx + 1
  	end
  	if _joystick:isGamepadDown("dpup") then 
  		ky = ky - 1
  	end
  	if _joystick:isGamepadDown("dpdown") then 
  		ky = ky + 1
  	end
  end 

  self.player.requestMoveX = kx
  self.player.requestMoveY = ky

  -- update the objects in the Level
  self:recalculate_view()
  self.level:update(dt, self.view)

  -- create more teddies 
  if self.level:countObject(GameObject.TYPE.ENEMY) < 10 then
    self.level:addObject(Enemy(
        self.player.x, 
        0, 64, 128))
  end
  
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
  local cam_left  = self.cam_x - self.view.w/2
  local cam_right = cam_left + self.view.w
  if cam_left < 0 then
    self.cam_x = self.view.w/2
  elseif cam_right > self.level.w then
    self.cam_x = self.level.w - self.view.w/2
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
  self:recalculate_view()
	
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
    local mountains_yoffset = 
      1000 - (self.view.y/8)%DEFAULT_H
    local horizon_offset = 
      base_offset - (self.view.x/30)%DEFAULT_W
    love.graphics.draw(HORIZON, QHORIZON, horizon_offset, 400)
    love.graphics.setColor(160, 61, 96)
      love.graphics.rectangle("fill", self.view.x, 
          400+HORIZON_H, self.view.w, 
          mountains_yoffset+MOUNTAINS_H-400-HORIZON_H)
    love.graphics.setColor(255, 255, 255)
      
    -- draw the background mountains
    local w, h = DEFAULT_W*SCALE_X/SCALE_MIN,
                  DEFAULT_H*SCALE_Y/SCALE_MIN
    local mountains_offset = 
      base_offset - (self.view.x/12)%DEFAULT_W
    if self.view.y < mountains_yoffset + MOUNTAINS_H then
      love.graphics.draw(MOUNTAINS, QMOUNTAINS, 
                          mountains_offset, mountains_yoffset)
    end
    love.graphics.setColor(104, 161, 127)
      love.graphics.rectangle("fill", 
          self.view.x, mountains_yoffset + MOUNTAINS_H, 
          self.view.w, 1550 - mountains_yoffset)
    love.graphics.setColor(255, 255, 255)
    
    -- draw the game objects
    self.level:draw(self.view)

  self.camera:detach()
  
  
  -- GUI
  --------------------------------------------
  
  
  -- if alive draw health-bars, etc
  if self.player.state ~= self.player.STATE.DEAD then
  
    -- calculate frames (quads) of life-bar and portraits
    local life_per_portrait = math.floor(Player.MAXLIFE/(#QPORTRAITS))
    local portrait = useful.clamp(
      math.floor(self.player.life / life_per_portrait) + 1,
      1, #QPORTRAITS)
      
    local life_per_colour = math.floor(Player.MAXLIFE/(#QBARS - 1))
    local colour_i = useful.clamp(
      #QBARS - 2 - math.floor(self.player.life / life_per_colour),
      1, #QBARS - 2)  

    local life_i = useful.clamp(math.floor(
        self.player.life/Player.MAXLIFE*BAR_DIVISIONS) + 1, 
            1, BAR_DIVISIONS)
    local magic_i = useful.clamp(math.floor(
        self.player.magic/Player.MAXMANA*BAR_DIVISIONS),
            1, BAR_DIVISIONS)
    local portrait_i = #QPORTRAITS - portrait + 1

    -- draw health-bar
    scaled_drawq(BARS, QBARS[5], 128, 32, 0, 2, 2)
    scaled_drawq(BARS, 
        QBARS[colour_i][life_i], 128, 32, 0, 2, 2)
    
    -- draw mana-bar 
    scaled_drawq(BARS, QBARS[5], 128, 108, 0, 2, 2)
    scaled_drawq(BARS, QBARS[#QPORTRAITS + 1][magic_i], 128, 108,
                  0, 2, 2)
    
    -- draw portrait
    scaled_drawq(PORTRAITS, 
        QPORTRAITS[portrait_i], 64, 32, 0, 2, 2)
   
    
  else
    scaled_draw(DEFEAT_SPLASH,
        DEFAULT_W/2 - DEFEAT_SPLASH:getWidth()/2,
        DEFAULT_H/2 - DEFEAT_SPLASH:getHeight()/2)
  end
  
  -- draw score 
  --love.graphics.print(self.player.score, 600, 32)
 
end

return state