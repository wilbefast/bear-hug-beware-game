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

local histoire1
local histoire2
local debut

function state:init()
  histoire1 = love.graphics.newImage( "assets/backgrounds/histoire1.jpg" )
  histoire2 = love.graphics.newImage( "assets/backgrounds/histoire2.jpg" )
end


function state:enter()
	debut = love.timer.getTime()
end


function state:focus()

end


function state:mousepressed(x, y, btn)

end


function state:mousereleased(x, y, btn)
	
end


function state:joystickpressed(joystick, button)
	
end


function state:joystickreleased(joystick, button)
	
end


function state:quit()
	
end


function state:keypressed(key, uni)
	if key=="escape" then
		love.event.push("quit")
  elseif key=="return" or key=="kpenter" then
    GameState.switch(game)
  end
end


function state:keyreleased(key, uni)
end


function state:update(dt)

	if( love.timer.getTime() > debut + 4 ) then
    	GameState.switch(game)
	end	
end


function state:draw()
	if( love.timer.getTime() > debut + 2 ) then
  		love.graphics.draw( histoire2 )
	else
  		love.graphics.draw( histoire1 )
	end

end

return state