Menu = class()

function Menu:load()
	self.sound = Sound()
	self.menuSounds = self.sound:loop({sound = 'menu'})
	self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
	self.creditsAlpha = 0
	love.mouse.setCursor(love.mouse.newCursor('media/graphics/cursor.png'))

  love.keyboard.setKeyRepeat(true)
  
  if self.menuSounds then self.menuSounds:stop() end

  self.hub = MenuHub()

  self.pages = {}
  self.pages.login = MenuLogin()
  self.pages.main = MenuMain()

  self.page = 'login'

  --[[local http = require('socket.http')
  local json = require('spine-love/dkjson')
  local token = http.request('http://96.126.101.55:7000/login', 'username=trey&password=test')
  print('logged in.  token is ' .. token)
  self.hub = require('socket').tcp()
  local success, e = self.hub:connect('96.126.101.55', 7001)
  if e then print('could not connect to hub')
  else print('connected to hub') end

  local str = json.encode({token = token, cmd = 'connect', payload = {token = token}}) .. '\n'
  print('sending ' .. str)

  self.hub:send(str)

  str = json.encode({token = token, cmd = 'lobbyCreate', payload = {}}) .. '\n'
  print('sending ' .. str)

  self.hub:send(str)

  local data = self.hub:receive('*l')
  print('received ' .. data)
  table.print(json.decode(data))

  str = json.encode({token = token, cmd = 'lobbyQueue', payload = {}}) .. '\n'
  print('sending ' .. str)

  self.hub:send(str)

  local data = self.hub:receive('*l')
  print('received ' .. data)
  local config = json.decode(data).payload

  table.print(config)
  _G['config'] = config

  Context:remove(ctx)
  Context:add(Game)]]
end

function Menu:update()
  local page = self.pages[self.page]
	self.creditsAlpha = timer.rot(self.creditsAlpha)
  
  self.hub:update()

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

function Menu:keypressed(key)
  --
end

function Menu:keyreleased(key)
  --
end

function Menu:mousepressed(x, y, b)
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

