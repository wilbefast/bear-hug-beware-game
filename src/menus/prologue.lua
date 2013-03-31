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
PROLOGUE STORY PAGES
--]]------------------------------------------------------------

local PAGES = { }
local BACKGROUND = nil

local PAGE_DURATION = 4

function turnPage(self)
  self.currentPage = self.currentPage + 1
  if self.currentPage > #PAGES then
    GameState.switch(game)
  end
end

function unturnPage(self)
  self.currentPage = self.currentPage - 1
  if self.currentPage < 1 then
    GameState.switch(title)
  end
end

--[[------------------------------------------------------------
PROLOGUE GAME STATE
--]]------------------------------------------------------------

local state = GameState.new()

function state:init()
  
  -- background
  BACKGROUND = love.graphics.newImage("assets/menus/prologue_background.jpg")
  
  -- page 1
  local TEXT_1 = love.graphics.newImage("assets/menus/prologue1_fr.png")
  local BANISHED = love.graphics.newImage("assets/menus/banished.png")
  table.insert(PAGES, function() 
    scaled_draw(BANISHED, 242, 205)
    scaled_draw(TEXT_1, 700, 116)
  end)

  -- page 2
  local TEXT_2 = love.graphics.newImage("assets/menus/prologue2_fr.png")
  local HUGLAND = love.graphics.newImage("assets/menus/hugland.png")
  table.insert(PAGES, function() 
    scaled_draw(TEXT_2, 285, 198)
    scaled_draw(HUGLAND, 705, 159)
  end)
end

function state:enter()
  self.currentPage = 1
	self.pageTime = PAGE_DURATION
end

function state:keypressed(key, uni)
  -- return to main menu
  if key=="escape" then
    GameState.switch(title)
  -- skip
  elseif key=="return" or key=="kpenter" or key=="right" then
    turnPage(self)
  -- go back
  elseif key=="left" then
    unturnPage(self)
  end
end


function state:update(dt)
  -- countdown
  self.pageTime = self.pageTime - dt
  if self.pageTime <= 0 then
    turnPage(self)
    self.pageTime = PAGE_DURATION
  end
end


function state:draw()
  -- draw the background
  scaled_draw(BACKGROUND)
  
  -- draw the current page
  PAGES[self.currentPage]()
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state