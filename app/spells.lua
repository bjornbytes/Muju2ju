Spells = extend(Manager)

Spells.map = {
  [1] = 'spiritBomb',
  [2] = 'lightning',
  spiritBomb = 1,
  lightning = 2
}

function Spells:init()
  Manager.init(self)

  if ctx.tag == 'server' then
    ctx.event:on('spellCreate', function(data)
      data.kind = self.map[data.kind]
      self:add(data)
    end)
  else
    self.queue = {}
    ctx.event:on('spellCreate', function(data)
      data.kind = self.map[data.kind]
      if data.tick > tick then
        table.insert(self.queue, data)
      else
        local spell = self:add(data)
        for i = 1, tick - data.tick do
          spell:update()
        end
      end
    end)
  end
end

function Spells:update()
  if ctx.tag == 'client' then
    for i = 1, #self.queue do
      if self.queue[i].tick > tick then break end
      self.queue[i].tick = nil
      self:add(self.queue[i])
    end
  end

  Manager.update(self)
end
