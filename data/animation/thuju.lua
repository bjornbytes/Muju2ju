local Thuju = extend(Animation)
Thuju.code = 'thuju'

Thuju.scale = .35
Thuju.offsety = 64
Thuju.default = 'walk'
Thuju.states = {}

Thuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .21,
  mix = {
    walk = .2,
    death = .2
  }
}

Thuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73,
  mix = {
    death = .2
  }
}

Thuju.states.attack = {
  priority = 1,
  mix = {
    death = .2,
    walk = .2,
    taunt = .2,
    smash = .2
  }
}

Thuju.states.taunt = {
  priority = 2,
  blocking = true,
  loop = false,
  speed = 1,
  mix = {
    walk = .2,
    attack = .2
  }
}

Thuju.states.smash = {
  priority = 2,
  blocking = true,
  loop = false,
  mix = {
    walk = .2,
    attack = .2
  }
}

Thuju.states.death = {
  priority = 3,
  blocking = true,
  speed = .8,
  complete = function(self, owner)
    owner:die()
  end
}

return Thuju
