local sha1 = require 'lib/deps/sha1/sha1'

MenuPatcher = class()

function MenuPatcher:activate()
  self.hashes = {}
  self:patch()
end

function MenuPatcher:update()

end

function MenuPatcher:draw()

end

function MenuPatcher:hubMessage(message, data)
  ctx:push('main')
end

function MenuPatcher:patch()
  local ignore = {'.git', '.DS_Store', 'error.log'}
  local function halp(base)
    for _, file in ipairs(love.filesystem.getDirectoryItems(base)) do
      local path = base .. '/' .. file

      local ignored = false

      table.each(ignore, function(name)
        if path:find(name) then ignored = true return false end
      end)

      if not ignored then
        if love.filesystem.isDirectory(path) then
          halp(path)
        else
          table.insert(self.hashes, {path = path, hash = sha1(love.filesystem.read(path))})
        end
      end
    end
  end

  halp('')

  table.sort(self.hashes, function(a, b) return a.path < b.path end)
  self.hashes = table.map(self.hashes, function(entry) return entry.hash end)

  local patchHash = sha1(table.concat(self.hashes, ''))

  ctx:push('main')

  print('I patched with sha1 ' .. patchHash)
end
