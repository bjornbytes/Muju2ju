Menu = class()

function Menu:load()
	self.sound = Sound()
	self.menuSounds = self.sound:loop({sound = 'menu'})
	self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
	self.creditsAlpha = 0
	love.mouse.setCursor(love.mouse.newCursor('media/graphics/cursor.png'))

  self.hubThread = love.thread.newThread('app/hub/hub.lua')
  self.hubThread:start()

  love.keyboard.setKeyRepeat(true)
  
  if self.menuSounds then self.menuSounds:stop() end

  self.hub = MenuHub()

  self.pages = {}
  self.pages.login = MenuLogin()
  self.pages.main = MenuMain()

  self.page = 'main'
end

function Menu:update()
  local page = self.pages[self.page]
	self.creditsAlpha = timer.rot(self.creditsAlpha)
  
  self.hub:update()
  if self.hubThread:getError() then error(self.hubThread:getError()) end

  f.exe(page.update, page)
end

function Menu:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(data.media.graphics.mainMenu)
	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255, math.min(self.creditsAlpha * 255, 255))
	love.graphics.print('We do not mind who gets the credit.', 2, 0)

  local page = self.pages[self.page]
  f.exe(page.draw, page)
end

function Menu:keypressed(...) return self:with('keypressed', ...) end
function Menu:keyreleased(...) return self:with('keyreleased', ...) end
function Menu:mousepressed(...) return self:with('mousepressed', ...) end
function Menu:mousereleased(...) return self:with('mousereleased', ...) end
function Menu:textinput(...) return self:with('textinput', ...) end


function Menu:with(key, ...)
  local page = self.pages[self.page]
  f.exe(page[key], page, ...)
end
