MenuMain = class()

function MenuMain:init()
	self.gooey = Gooey(data.gooey.menu.main)
	self.gooey:find('exitButton'):on('clicked', function()
		love.event.quit()
	end)
	self.gooey:find('survivalButton'):on('clicked', function()
		Context:remove(ctx)
		Context:add(Game)
	end)
end

function MenuMain:update()
	self.gooey:update()
end

function MenuMain:draw()
	self.gooey:draw()
end

function MenuMain:keypressed(...) self.gooey:keypressed(...) end
function MenuMain:keyreleased(...) self.gooey:keyreleased(...) end
function MenuMain:mousepressed(...) self.gooey:mousepressed(...) end
function MenuMain:mousereleased(...) self.gooey:mousereleased(...) end
function MenuMain:textinput(...) self.gooey:textinput(...) end

