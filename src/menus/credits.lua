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

local state = GameState.new()

local MUSIC = love.audio.newSource("assets/audio/bisounours.ogg") 

function state:enter()
  MUSIC:play()
end



function state:leave()
  MUSIC:stop()
end


function state:keypressed(key, uni)
  if key=="escape" then
    love.event.push("quit")
    
  elseif key=="return" or key=="kpenter" then
    GameState.switch(histoire)
end


function state:keyreleased(key, uni)
end


function state:update(dt)
end


function state:draw()
  love.graphics.draw(current)
end

return state