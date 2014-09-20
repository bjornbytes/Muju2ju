Sound = class()

function Sound:init()
  self.muted = false
	self.sounds = {}
end

function Sound:play(_data)
  if self.muted then return end

  local sound = data.media.sounds[_data.sound]

	if sound then
		local instance = sound:play()
		return instance
	end

	return nil
end

function Sound:loop(data)
  local sound = self:play(data)
  if sound then sound:setLooping(true) end
  return sound
end

function Sound:mute()
  self.muted = not self.muted
  love.audio.tags.all.setVolume(self.muted and 0 or 1)
end
