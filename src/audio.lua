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


local audio = {}

-- loading
function audio:load(filename, type)
  local filepath = ("assets/audio/" .. filename .. ".ogg")
  local file = love.audio.newSource(filepath, type)
  self[filename] = file
end

function audio:load_sound(filename)
  self:load(filename, "static")
end

function audio:load_music(filename)
  self:load(filename, "stream")
end

-- playing
function audio:play_music(name)
  local new_music = self[name]
  if new_music ~= self.music then
    if self.music then
      self.music:stop()
    end
    new_music:play()
    self.music = new_music
  end
end

function audio:play_sound(name)
  if not name then return end
  
  self[name]:play()
  --TODO
end

-- export
return audio