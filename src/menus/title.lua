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
RESOURCES
--]]------------------------------------------------------------

local MUSIC, BACKGROUND, TITLE, PLAY, CREDITS

--[[------------------------------------------------------------
MAIN MENU (TITLE)
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
  -- load resources
  MUSIC = love.audio.newSource("assets/audio/bisounours.ogg")
  BACKGROUND = love.graphics.newImage("assets/menus/menu_background.jpg")
  TITLE = love.graphics.newImage("assets/menus/title.png")
  PLAY = love.graphics.newImage("assets/menus/button_play.png")
  CREDITS = love.graphics.newImage("assets/menus/button_credits.png")
end

function state:enter()
  --MUSIC:play()
end


function state:leave()
  MUSIC:stop()
end


function state:keypressed(key, uni)
  -- quit game
  if key=="escape" or key =="left" then
    love.event.push("quit")
  -- go to prologue
  elseif key=="return" or key=="kpenter" or key=="right" then
    GameState.switch(prologue)
  end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
end


function state:draw()
  -- draw the background
  scaled_draw(BACKGROUND)
  
  -- draw the title
  scaled_draw(TITLE, 370, 42)
  
  -- draw the buttons
  --scaled_draw(PLAY, 840, 390)
  --scaled_draw(CREDITS, 840, 390)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state