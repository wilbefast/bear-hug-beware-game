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

GameState = require("hump/gamestate")
conf = require("conf")
game = require("game")
audio = require("audio")

local useful = require("useful")

local SCREENSHOT_KEY = "x"
local _capture_gif = false



WINDOW_W = 0
WINDOW_H = 0

--[[------------------------------------------------------------
GLOBAL SETTINGS
--]]------------------------------------------------------------

DEBUG = true
audio.mute = (DEBUG == true)
CAN_CAPTURE_GIF = false

--[[------------------------------------------------------------
DEAL WITH DIFFERENT RESOLUTIONS (scale images)
--]]------------------------------------------------------------

DEFAULT_W, DEFAULT_H, SCALE_X, SCALE_Y, SCALE_MIN, SCALE_MAX = 1280, 720, 1, 1, 1, 1

function scaled_draw(img, x, y, rot, sx, sy)
  x, y, rot, sx, sy = (x or 0), (y or 0), (rot or 0), (sx or 1), (sy or 1)
  love.graphics.draw(img, x*SCALE_MIN + DEFAULT_W*(SCALE_X-SCALE_MIN)/2, 
                          y*SCALE_MIN + DEFAULT_H*(SCALE_Y-SCALE_MIN)/2, 
                          rot, 
                          sx*SCALE_MIN, 
                          sy*SCALE_MIN)
end

function scaled_drawq(img, quad, x, y, rot, sx, sy)
  x, y, rot, sx, sy = (x or 0), (y or 0), (rot or 0), (sx or 1), (sy or 1)
  love.graphics.draw(img, quad, x*SCALE_MIN, --+ DEFAULT_W*(SCALE_X-SCALE_MIN)/2, 
                                  y*SCALE_MIN, --+ DEFAULT_H*(SCALE_Y-SCALE_MIN)/2, 
                                  rot, 
                                  sx*SCALE_MIN, 
                                  sy*SCALE_MIN)
end

local function setBestResolution(desired_w, desired_h, fullscreen)
  DEFAULT_W, DEFAULT_H = desired_w, desired_h
  -- get and sort the available screen modes from best to worst
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) 
    return ((a.width*a.height > b.width*b.height) 
          and (a.width <= desired_w) and a.height <= desired_h) end)
       
  -- try each mode from best to worst
  for i, m in ipairs(modes) do
    
    if DEBUG then
      m = modes[#modes - 1]
    end
    
    -- try to set the resolution
    local success = love.window.setMode(m.width, m.height, { fullscreen = true } )
    if success then
      SCALE_X, SCALE_Y = m.width/desired_w, m.height/desired_h
      SCALE_MIN, SCALE_MAX = math.min(SCALE_X, SCALE_Y), math.max(SCALE_X, SCALE_Y)
      return true -- success!
    
    end
  end
  return false -- failure!
end

--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)
    
  -- set up the screen resolution
  if (not setBestResolution(1280, 720, (not DEBUG))) then --FIXME
    print("Failed to set mode")
    love.event.push("quit")
  end
  WINDOW_W = love.graphics.getWidth()
  WINDOW_H = love.graphics.getHeight()
  
  -- load sound and music
  audio:load_sound("bear_attack", 3)  
  audio:load_sound("bear_die", 3)
  audio:load_sound("jump", 2)  
  audio:load_sound("magic", 2)  
  audio:load_sound("disgust", 2)
  audio:load_sound("punch", 4)
  audio:load_sound("miss", 4)
  audio:load_music("music_game") 

  -- load font
  FONT_DEFAULT = love.graphics.newFont(14)
  FONT_SMALL = love.graphics.newFont("assets/ttf/APACAXI_COMIC.ttf", 64)
  FONT_LARGE = love.graphics.newFont("assets/ttf/APACAXI_COMIC.ttf", 128)
  FONT_LARGE_OUTLINE = love.graphics.newFont("assets/ttf/APACAXI_COMIC.ttf", 136)
  love.graphics.setFont(FONT_LARGE)
  FONT_HUGE = love.graphics.newFont("assets/ttf/APACAXI_COMIC.ttf", 256)
  FONT_HUGE_OUTLINE = love.graphics.newFont("assets/ttf/APACAXI_COMIC.ttf", 264)
 
  -- initialise random
  math.randomseed(os.time())
  
  -- hide the mouse
  love.mouse.setVisible(false)

  -- go to the initial gamestate
  GameState.switch(game)
end

function love.focus(f)
  GameState.focus(f)
end

function love.quit()
  GameState.quit()
end

function love.keypressed(key, uni)
  GameState.keypressed(key, uni)

  if CAN_CAPTURE_GIF and (key == SCREENSHOT_KEY) then
  	_capture_gif = (not _capture_gif)
  end
end

function love.keyreleased(key, uni)
  GameState.keyreleased(key, uni)
end

function love.joystickpressed( joystick, button )
	GameState.joystickpressed(joystick, button)
end

function love.joystickreleased( joystick, button )
	GameState.joystickreleased(joystick, button)
end


MIN_DT = 1/60
MAX_DT = 1/30
function love.update(dt)
  if _capture_gif then
    dt = MAX_DT
  else
  	dt = math.max(MIN_DT, math.min(MAX_DT, dt))
  end

  GameState.update(dt)
end

function love.draw()
	love.graphics.setFont(FONT_DEFAULT)
  GameState.draw()

  -- capture GIF footage
  if _capture_gif then
    useful.recordGIF()
  end
end
