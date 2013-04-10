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

local useful = require("useful")

--[[------------------------------------------------------------
RESOURCES
--]]------------------------------------------------------------

local MUSIC, BACKGROUND, TITLE, PLAY, CREDITS, CREDITS_TEXT
local QUAD_ON = love.graphics.newQuad(0, 0, 512, 256, 512, 512)
local QUAD_OFF = love.graphics.newQuad(0, 256, 512, 256, 512, 512)
local N_OPTIONS = 2

--[[------------------------------------------------------------
MAIN MENU (TITLE)
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
  -- load resources
  BACKGROUND = love.graphics.newImage("assets/menus/menu_background.jpg")
  TITLE = love.graphics.newImage("assets/menus/title.png")
  PLAY = love.graphics.newImage("assets/menus/button_play.png")
  CREDITS = love.graphics.newImage("assets/menus/button_credits.png")
  CREDITS_TEXT = love.graphics.newImage("assets/menus/credits_fr.png")
  
  -- only display splash screen the first time
  self.timer = 1
end

function state:enter()
  -- reset options
  self.option = 1
  self.credits = false
  
  -- restart music
  audio:play_music("music_title")
end


function state:leave()
end


function state:keypressed(key, uni)
  
  -- end the splash-screen timer prematurely
  if self.timer > 0 then
    self.timer = 0
    return
  end
  
  -- leave the credits screen
  if self.credits then 
    self.credits = false
    return
  end
  
  -- quit game
  if key=="escape" then
    love.event.push("quit")
    
  -- select current option
  elseif key=="return" or key=="kpenter" then
    if self.option == 1 then
      GameState.switch(prologue)
    else
      self.credits = true
    end
    
  -- change option
  elseif key =="left" or key=="up" then
    if self.option == 1 then
      self.option = N_OPTIONS
    else
      self.option = (self.option - 1)
    end
  elseif key =="right" or key=="down" then
    if self.option == N_OPTIONS then
      self.option = 1
    else
      self.option = (self.option + 1)
    end
  end
end


function state:update(dt)
  if self.timer > 0 then
    self.timer = self.timer - dt
  end
end


function state:draw()
  -- draw the background
  scaled_draw(BACKGROUND)
  
  
  -- draw the title splash-screen
  if self.timer > 0 then
    scaled_draw(TITLE, 310, 42)
  
  -- draw the credits
  elseif self.credits then
    scaled_draw(CREDITS_TEXT, 330, 330)
    
  -- draw the buttons
  else
    scaled_drawq(PLAY, useful.tri(self.option == 1, QUAD_ON, QUAD_OFF), 400, 370)
    scaled_drawq(CREDITS, useful.tri(self.option == 2,QUAD_ON, QUAD_OFF), 900, 450)
    
  end
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state