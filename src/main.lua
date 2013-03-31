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
title = require("menus/title")
prologue = require("menus/prologue")
game = require("game")


--[[------------------------------------------------------------
DEAL WITH DIFFERENT RESOLUTIONS (scale images)
--]]------------------------------------------------------------

local SCALE_X, SCALE_Y = 1, 1

function scaled_draw(img, x, y, rot, sx, sy)
  x, y, rot, sx, sy = (x or 0), (y or 0), (rot or 0), (sx or 1), (sy or 1)
  love.graphics.draw(img, x*SCALE_X, y*SCALE_Y, rot, sx*SCALE_X, sy*SCALE_Y)
end

function scaled_drawq(img, quad, x, y, rot, sx, sy)
  x, y, rot, sx, sy = (x or 0), (y or 0), (rot or 0), (sx or 1), (sy or 1)
  love.graphics.drawq(img, quad, x*SCALE_X, y*SCALE_Y, rot, sx*SCALE_X, sy*SCALE_Y)
end

local function setBestResolution(desired_w, desired_h, fullscreen)
  -- get and sort the available screen modes from best to worst
  local modes = love.graphics.getModes()
  table.sort(modes, function(a, b) 
    return a.width*a.height < b.width*b.height end) --FIXME
    
  -- try each mode from best to worst
  for i, m in ipairs(modes) do
    -- try to set the resolution
    local success = love.graphics.setMode(m.width, m.height, fullscreen)
    if success then
      SCALE_X, SCALE_Y = m.width/desired_w, m.height/desired_h
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
  if (not setBestResolution(1280, 720, false)) then --FIXME
    print("Failed to set mode")
    love.event.push("quit")
  end
  
  -- go to the initial gamestate
  GameState.switch(title)
end

function love.focus(f)
  GameState.focus(f)
end

function love.quit()
  GameState.quit()
end

function love.keypressed(key, uni)
  GameState.keypressed(key, uni)
end

function keyreleased(key, uni)
  GameState.keyreleased(key)
end

MAX_DT = 1/60
function love.update(dt)
  dt = math.min(MAX_DT, dt)
  GameState.update(dt)
end

function love.draw()
  GameState.draw()
end
