local http = require('socket.http')

MenuLogin = class()

function MenuLogin:init()
  self.gooey = Gooey(data.gooey.menu.login)

  self.username = self.gooey:find('username')
  self.password = self.gooey:find('password')

  self.gooey:find('loginButton'):on('clicked', f.cur(self.authenticate, self))

	self.gooey:find('exitButton'):on('clicked', function() 
		love.event.quit()
	end)

  self.username:on('keypressed', function(data)
    if data.key == 'tab' then self.gooey:focus(self.password) end
  end)

  self.password:on('keypressed', function(data)
    if love.keyboard.isDown('lshift') and data.key == 'tab' then self.gooey:focus(self.username)
    elseif data.key == 'enter' then
      self:authenticate()
    end
  end)
end

function MenuLogin:update()
  self.gooey:update()
end

function MenuLogin:draw()
  self.gooey:draw()
end

function MenuLogin:keypressed(...) self.gooey:keypressed(...) end
function MenuLogin:keyreleased(...) self.gooey:keyreleased(...) end
function MenuLogin:mousepressed(...) self.gooey:mousepressed(...) end
function MenuLogin:mousereleased(...) self.gooey:mousereleased(...) end
function MenuLogin:textinput(...) self.gooey:textinput(...) end

function MenuLogin:authenticate()
  local username, password = self.username.text, self.password.text
  ctx.hub:send('login', {username = username, password = password})

  -- set up loading spinner!
end

function MenuLogin:loggedIn(data)
  if not data.error then
    ctx.page = 'main'
    ctx.userState.token = data.token
  else
    print('login failed')
  end
end
