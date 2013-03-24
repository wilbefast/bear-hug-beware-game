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

function state:init()
  fic = "assets/audio/bisounours.ogg"
  bisous = love.audio.newSource(fic)

  debut = love.timer.getTime()
  bg1 = love.graphics.newImage( "assets/backgrounds/accueilTitre.jpg" )
  bg2 = love.graphics.newImage( "assets/backgrounds/accueilPlay.jpg" )
  bgcredits = love.graphics.newImage( "assets/backgrounds/accueilPlaySurvolCredit.jpg" )
  bgplay = love.graphics.newImage( "assets/backgrounds/accueilPlaySurvolPlay.jpg" )
  current = bg1
	  
end


function state:enter()

  love.mouse.setVisible( true )
  bisous:play()
  bisous:setLooping(true)
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

function state:leave()
bisous:setLooping(false)
bisous:stop()
end


function state:keypressed(key, uni)
  if key=="escape" then
    love.event.push("quit")
  elseif key=="return" or key=="kpenter" then
    GameState.switch(histoire)
  
  elseif key=="x"  then
    GameState.switch(fin)
  end
end


function state:keyreleased(key, uni)
end


function state:update(dt)
  local x, y = love.mouse.getPosition()

  if( love.timer.getTime() > debut + 2 ) then
      current=  bg2
  end

  if( x > 344 and y > 348 and x < 720 and y < 600) then
      current=  bgplay
      if( love.mouse.isDown("r","l") ) then
        GameState.switch(histoire)
      end
  end

  if( x > 805 and y > 600 and x < 1135 and y < 679) then
      current=  bgcredits
      if( love.mouse.isDown("r","l") ) then
        GameState.switch(credits)
      end
  end

end


function state:draw()
  --love.graphics.print("Press Enter to play", 32, 32)


  love.graphics.draw( current )
end

return state