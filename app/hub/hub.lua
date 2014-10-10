local hub = require('socket').tcp()
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
  local str = ''
  for k, v in pairs(data) do
    str = str .. k .. '=' .. v .. '&'
  end
  return str:substr(0, #str - 1)
end

local success, e = hub:connect(serverAddress, 7001)
if e then error(e) end

hub:settimeout(100)

while true do

  -- Receive stuff
  local line, e = hub:receive('*a')
  carry(line)

  -- Send stuff
  local message = sendQueue:pop()
  while message do
    if message.cmd == 'login' then
      local str = http.request(serverAddress .. '/login', formatPost(message.payload))
      receiveQueue:push(json.decode(str))
    else
      line:send(json.encode(message))
    end
    message = sendQueue:pop()
  end
end

