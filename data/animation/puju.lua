local Puju = extend(Animation)
Puju.code = 'puju'

Puju.initial = 'attack'
Puju.animations = {}

Puju.animations.attack = {
  priority = 1,
  loop = true,
  speed = function(self, owner) return .8 * owner.attackAnimation end,
  mix = {
    heabutt = .2
  }
}

Puju.animations.headbutt = {
  priority = 1,
  speed = .69,
  mix = {
    attack = .2
  },
  complete = 'attack'
}

Puju.on = {
  headbutt = function(self, owner, event)
    print('headbutt!')
  end
}

return Puju
