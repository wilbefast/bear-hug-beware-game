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

local useful = require("useful")

local audio = {}

-- loading
function audio:load(filename, type)
  local filepath = ("assets/audio/" .. filename .. ".ogg")
  return love.audio.newSource(filepath, type)
end

function audio:load_sound(filename, n_sources)
  n_sources = (n_sources or 1)
  self[filename] = {}
  for i = 1, n_sources do 
    self[filename][i] = self:load(filename, "static")
  end
end

function audio:load_music(filename)
  self[filename] = self:load(filename, "stream")
end

-- playing
function audio:play_music(name)
  local new_music = self[name]
  if new_music ~= self.music then
    if self.music then
      self.music:stop()
    end
    --new_music:play()
    self.music = new_music
  end
end

function audio:play_sound(name, pitch_shift, x, y)
  if not name then return end
  for _, src in ipairs(self[name]) do
    if src:isStopped() then
      
      -- shift the pitch
      if pitch_shift and (pitch_shift ~= 0) then
        src:setPitch(1 + useful.signedRand(pitch_shift))
      end
      
      -- use 3D sound
      if x and y then
        src:setPosition(x, y, 0)
      end
      
      src:play()
      return
    end
  end
end

-- export
return audio