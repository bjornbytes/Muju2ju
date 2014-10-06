local function load(dir)
	for _, file in pairs(love.filesystem.getDirectoryItems(dir)) do
		local path = dir .. '/' .. file
		if string.find(path, '%.lua') and not string.find(path, '%..+%.lua') then
			require(path:gsub('%.lua', ''))
		end
	end

	if love.filesystem.exists(dir .. '.lua') then require(dir) end
end

require 'spine-love.spine'
require 'enet'

load 'lib/deps/lutil'
if love.audio then
  load 'lib/deps/slam'
end
load 'lib'

load 'app/particles'
load 'app/effects'

load 'app/ctx'
load 'app/hud'
load 'app'
