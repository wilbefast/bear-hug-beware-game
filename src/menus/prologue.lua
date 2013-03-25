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
  table.insert(PAGES, love.graphics.newImage("assets/menus/prologue1.jpg"))
  table.insert(PAGES, love.graphics.newImage("assets/menus/prologue2.jpg"))
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
  if self.pageTime < PAGE_DURATION then
    turnPage(self)
  end
end


function state:draw()
  -- draw the current page
  love.graphics.draw(PAGES[self.currentPage])
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state