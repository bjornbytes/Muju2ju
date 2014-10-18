local http = require('socket.http')

MenuSignup = class()

function MenuSignup:init()
  self.gooey = Gooey(data.gooey.menu.signup)

  self.username = self.gooey:find('username')
  self.password = self.gooey:find('password')
  self.passwordRetype = self.goeey:find('passwordRetype')

  local tab = function(to)
    return function(data)
      if data.key == 'tab' then
        self.gooey:focus(to)
      end
    end
  end

  self.gooey:find('signupButton'):on('clicked', f.cur(self.signup, self))
  self.username:on('keypressed', tab(self.password))
  self.password:on('keypressed', tab(self.passwordRetype))
end

function MenuSignup:update()
  self.gooey:update()
end

function MenuSignup:draw()
  self.gooey:draw()
end

function MenuSignup:keypressed(...) self.gooey:keypressed(...) end
function MenuSignup:keyreleased(...) self.gooey:keyreleased(...) end
function MenuSignup:mousepressed(...) self.gooey:mousepressed(...) end
function MenuSignup:mousereleased(...) self.gooey:mousereleased(...) end
function MenuSignup:textinput(...) self.gooey:textinput(...) end

function MenuSignup:signup()
  local username = self.username.text
  local password, passwordRetype = self.password.text, self.passwordRetype.tet

  if password == passwordRetype then
    ctx.hub:send('signup', {username = username, password = password})
  else
    print('Passwords did not match.')  
  end
end

function MenuSignup:signedUp(data)
  if not data.error then
    ctx.page = 'main'
    ctx.userState.token = data.token
  else
    print(data.error)
  end
end
