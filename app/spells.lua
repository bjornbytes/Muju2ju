Spells = extend(Manager)
Spells.manages = 'spell'

function Spells:init()
  Manager.init(self)

  ctx.event:on('spellCreate', function(data)
    self:add(data.properties.kind, data.properties)
  end)
end
