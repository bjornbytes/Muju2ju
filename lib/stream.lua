Stream = class()

local function byteExtract(x, a, b)
  b = b or a
  x = x % (2 ^ (b + 1))
  for i = 1, a do
    x = math.floor(x / 2)
  end
  return x
end

local function byteInsert(x, y, a, b)
  local res = x
  for i = a, b do
    local e = byteExtract(y, i - a)
    if e ~= byteExtract(x, i) then
      res = (e == 1) and res + (2 ^ i) or res - (2 ^ i)
    end
  end
  return res
end

function Stream:init(str)
  self.str = str or ''
  self.byte = nil
  self.byteLen = nil
  getmetatable(self).__tostring = self.truncate
end

function Stream:truncate()
  if self.byte then
    self.str = self.str .. string.char(self.byte)
    self.byte = nil
    self.byteLen = nil
  end

  return self.str
end

function Stream:clear()
  self.str = ''
  self.byte = nil
  self.byteLen = nil
  return self
end

function Stream:write(x, sig)
  if type(sig) == 'number' then self:writeBits(x, sig)
  elseif sig == 'string' then self:writeString(x)
  elseif sig == 'bool' then self:writeBool(x)
  elseif sig == 'float' then self:writeFloat(x)
  elseif sig == 'animation' then self:writeAnimation(x)
  elseif sig == 'spell' then self:writeSpell(x) end
  
  return self
end

function Stream:writeString(string)
  self:truncate()
  string = tostring(string)
  self.str = self.str .. string.char(#string) .. string
end

function Stream:writeBool(bool)
  local x = bool and 1 or 0
  self:writeBits(x, 1)
end

function Stream:writeFloat(float)
  local negative = float < 0
  float = math.abs(float)
  self:writeBool(negative)
  self:writeBits(math.floor(float), 14)
  self:writeBits(math.round((float - math.floor(float)) * 1000), 10)
end

function Stream:writeBits(x, n)
  local idx = 0
  repeat
    if not self.byte then self.byte = 0 self.byteLen = 0 end
    local numWrite = math.min(n, (7 - self.byteLen) + 1)
    local toWrite = byteExtract(x, idx, idx + (numWrite - 1))
    self.byte = byteInsert(self.byte, toWrite, self.byteLen, self.byteLen + (numWrite - 1))
    self.byteLen = self.byteLen + numWrite
    
    if self.byteLen == 8 then
      if self.byte < 0 or self.byte > 255 then print(self.byte) end
      self.str = self.str .. string.char(self.byte)
      self.byte = nil
      self.byteLen = nil
    end
    
    n = n - numWrite
    idx = idx + numWrite
  until n == 0
end

function Stream:writeAnimation(animation)
  self:writeBits(animation.index, 4)
  self:writeBits(math.round(animation.time * 255), 8)
  self:writeBool(animation.flipped)
  self:writeBool(animation.mixing)
  if animation.mixing then
    self:writeBits(animation.mixWith, 4)
    self:writeBits(math.round(animation.mixTime * 255), 8)
    self:writeBits(math.round(animation.mixAlpha * 255), 8)
  end
end

function Stream:writeSpell(spell)
  if spell.kind == 'burst' then
    self:writeBits(1, 4)
    self:writeBits(math.round(spell.x), 16)
    self:writeBits(math.round(spell.y), 16)
    self:writeBits(math.round(spell.radius), 10)
  end
end

function Stream:read(kind)
  if type(kind) == 'number' then return self:readBits(kind)
  elseif kind == 'string' then return self:readString()
  elseif kind == 'bool' then return self:readBool()
  elseif kind == 'float' then return self:readFloat()
  elseif kind == 'animation' then return self:readAnimation()
  elseif kind == 'spell' then return self:readSpell() end
end

function Stream:readString()
  if self.byte then
    self.str = self.str:sub(2)
    self.byte = nil
    self.byteLen = nil
  end
  local len = self.str:byte(1)
  local res = ''
  if len then
    self.str = self.str:sub(2)
    res = self.str:sub(1, len)
    self.str = self.str:sub(len + 1)
  end
  return res
end

function Stream:readBool()
  return self:readBits(1) > 0
end

function Stream:readFloat()
  local negative = self:readBool()
  local number = self:readBits(14)
  local decimal = self:readBits(10)
  number = number + decimal / 1000
  if negative then number = -number end
  return number
end

function Stream:readBits(n)
  local x = 0
  local idx = 0
  while n > 0 do
    if not self.byte then self.byte = self.str:byte(1) or 0 self.byteLen = 0 end
    local numRead = math.min(n, (7 - self.byteLen) + 1)
    x = x + (byteExtract(self.byte, self.byteLen, self.byteLen + (numRead - 1)) * (2 ^ idx))
    self.byteLen = self.byteLen + numRead
    
    if self.byteLen == 8 then
      self.str = self.str:sub(2)
      self.byte = nil
      self.byteLen = nil
    end
    
    n = n - numRead
    idx = idx + numRead
  end

  return x
end

function Stream:readAnimation()
  local animation = {}
  animation.index = self:readBits(4)
  animation.time = self:readBits(8) / 255
  animation.flipped = self:readBool()
  animation.mixing = self:readBool()
  if animation.mixing then
    animation.mixWith = self:readBits(4)
    animation.mixTime = self:readBits(8) / 255
    animation.mixAlpha = self:readBits(8) / 255
  end

  return animation
end

function Stream:readSpell()
  local properties = {}
  local kind = self:readBits(4)
  if kind == 1 then
    properties.kind = 'burst'
    properties.x = self:readBits(16)
    properties.y = self:readBits(16)
    properties.radius = self:readBits(10)
  end

  return properties
end

function Stream:pack(data, signature)
  if not signature.data then return end

  local function halp(data, signature, order, delta)
    local keys
    if delta then
      keys = {}
      for _, key in ipairs(delta) do
        if type(key) == 'table' then
          local has = 0
          for i = 1, #key do
            if data[key[i]] ~= nil then
              keys[key[i]] = true
              has = has + 1
            else
              keys[key[i]] = false
            end
          end
          if has == 0 then self:write(0, 1)
          elseif has == #key then self:write(1, 1)
          else error('only part of message delta group "' .. table.concat(key, ', ') .. '" was provided.') end
        else
          self:write(data[key] ~= nil and 1 or 0, 1)
          keys[key] = data[key] ~= nil and true or false
        end
      end
    end

    for _, key in ipairs(order) do
      local format = signature[key]
      if not keys or keys[key] ~= false then
        if type(format) == 'table' then
          self:write(#data[key], 8)
          for i = 1, #data[key] do halp(data[key][i], format, order[key], delta and delta[key]) end
        else
          assert(data[key] ~= nil, 'stream: nil value for ' .. key)
          self:write(data[key], format)
        end
      end
    end
  end

  halp(data, signature.data, signature.order, signature.delta)
end

function Stream:unpack(signature)
  if not signature.data then return end

  local function halp(signature, order, delta)
    local keys
    if delta then
      keys = {}
      for i = 1, #delta do
        local val = self:read(1) > 0
        if type(delta[i]) == 'table' then
          for j = 1, #delta[i] do keys[delta[i][j]] = val end
        else
          keys[delta[i]] = val
        end
      end
    end

    local data = {}
    for _, key in ipairs(order) do
      local format = signature[key]
      if not keys or keys[key] ~= false then
        if type(format) == 'table' then
          local ct = self:read(8)
          data[key] = {}
          for i = 1, ct do
            local entry = halp(signature[key], order[key], delta and delta[key])
            table.insert(data[key], entry)
          end
        else
          data[key] = self:read(format)
        end
      end
    end
    
    return data
  end

  return halp(signature.data, signature.order, signature.delta)
end
