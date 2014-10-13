Spells = extend(Manager)
Spells.manages = 'spell'

Spells.map = {
  [1] = 'spiritBomb',
  [2] = 'lightning',
  [3] = 'burst',
  spiritBomb = 1,
  lightning = 2,
  burst = 3
}

function Spells:init()
  Manager.init(self)

  if ctx.tag == 'server' then
    --[[ctx.event:on('spellCreate', function(data)
      data.kind = self.map[data.kind]
      self:add(data.kind, data)
    end)]]
  else
    self.queue = {}
    --[[ctx.event:on('spellCreate', function(data)
      data.kind = self.map[data.kind]
      if data.tick > tick then
        table.insert(self.queue, data)
      else
        local spell = self:add(data)
        for i = 1, tick - data.tick do
          spell:update()
        end
      end
    end)]]
  end
end

function Spells:update()
  if ctx.tag == 'client' then
    for i = 1, #self.queue do
      if self.queue[i].tick > tick then break end
      self.queue[i].tick = nil
      self:add(self.queue[i].kind, self.queue[i])
    end
  end

  Manager.update(self)
end
