MenuMain = class()

function MenuMain:init()

end

function MenuMain:update()

end

function MenuMain:draw()

end

function MenuMain:mousepressed(x, y, b)
	if math.inside(x, y, 435, 220, 190, 90) then
		if self.menuSounds then self.menuSounds:stop() end
		Context:remove(ctx)
		Context:add(Game)
	elseif math.inside(x, y, 425, 335, 210, 90) then
		print('Harry Truman bitch!')
		self.creditsAlpha = 2
	elseif math.inside(x, y, 455, 445, 160, 90) then
		love.event.quit()
	end
end

