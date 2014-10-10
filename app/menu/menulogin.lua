local http = require('socket.http')

MenuLogin = class()

function MenuLogin:init()
  self:authenticate('trey', 'test')
end

function MenuLogin:update()

end

function MenuLogin:draw()
  -- draw boxes and text boxes
end

function MenuLogin:authenticate(username, password)
  local token, err = http.request('http://96.126.101.55:7000/login', 'username=' .. username .. '&password=' .. password)
  if err then print(err) end

  ctx.token = token
end
