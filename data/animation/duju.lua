local Duju = extend(Animation)
Duju.code = 'duju'

Duju.scale = 1
Duju.initial = 'attack'
Duju.animations = {}

Duju.animations.attack = {
  priority = 1,
  loop = true,
  speed = function(self, owner) return .8 * owner.attackAnimation end,
  mix = {
    heabutt = .2
  }
}

Duju.animations.headbutt = {
  priority = 1,
  speed = .69,
  mix = {
    attack = .2
  }
}

return Duju
