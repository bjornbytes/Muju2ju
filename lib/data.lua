media = {}

media.load = function()
	local function lookup(ext, fn)
		local function halp(s, k)
			local base = s._path .. '/' .. k
			if love.filesystem.exists(base .. ext) then
				s[k] = fn(base .. ext)
			elseif love.filesystem.isDirectory(base) then
				local t = {}
				t._path = base
				setmetatable(t, {__index = halp})
				s[k] = t
			end

			return rawget(s, k)
		end

		return halp
	end

	media.graphics = setmetatable({_path = 'media/graphics'}, {__index = lookup('.png', love.graphics.newImage)})
	media.shaders = setmetatable({_path = 'media/shaders'}, {__index = lookup('.shader', love.graphics.newShader)})
	media.sounds = setmetatable({_path = 'media/sounds'}, {__index = lookup('.ogg', love.audio.newSource)})
end

