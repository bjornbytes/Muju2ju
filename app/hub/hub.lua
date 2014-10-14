local hub = require('socket').tcp()
local http = require('socket.http')
local json = require('spine-love/dkjson')

local receiveQueue = love.thread.getChannel('hubReceiveQueue')
local sendQueue = love.thread.getChannel('hubSendQueue')

local serverAddress = '96.126.101.55'

local buffer = ''
local function carry(line)
  if not line then return end
  buffer = buffer .. line
  while true do
    local idx = buffer:find('\n')
    if not idx then break end
    local message = buffer:substr(1, idx)
    receiveQueue:push(json.decode(line))
    buffer = buffer:substr(idx + 1)
  end
end

local function formatPost(data)
  if not data then return '' end
  local t = {}
  for k, v in pairs(data) do t[#t + 1] = k .. '=' .. v end
  return table.concat(t, '&')
end

local success, e = hub:connect(serverAddress, 7001)
if e then error(e) end

hub:settimeout(.1)

while true do

  -- Receive stuff
  local line, e = hub:receive(1000)
  carry(line)

  -- Send stuff
  local data = sendQueue:pop()
  while data do
    local message = {cmd = data.cmd}
    data.cmd = nil
    message.payload = data

    if message.cmd == 'login' then
      local str, code = http.request('http://' .. serverAddress .. ':7000/login', formatPost(message.payload))

      local data
      if code == 200 then
        data = {cmd = 'login', token = str}
      elseif code == 401 then
        data = {cmd = 'login', error = 'authentication'}
      else
        data = {cmd = 'login', error = 'unknown'}
      end

      receiveQueue:push(data)
    else
      line:send(json.encode(data))
    end

    data = sendQueue:pop()
  end
end

