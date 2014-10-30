local Thuju = extend(Animation)
Thuju.code = 'thuju'

Thuju.scale = .25
Thuju.offsety = 64
Thuju.initial = 'walk'
Thuju.animations = {}

Thuju.animations.walk = {
  priority = 1,
  loop = true,
  speed = .73,
  mix = {
    death = .2
  }
}

Thuju.animations.attack = {
  priority = 1,
  mix = {
    death = .2,
    walk = .2,
    taunt = .2,
    smash = .2
  },
  complete = 'walk'
}

Thuju.animations.taunt = {
  priority = 2,
  loop = false,
  speed = 1,
  mix = {
    walk = .2,
    attack = .2
  }
}

Thuju.animations.smash = {
  priority = 2,
  loop = false,
  mix = {
    walk = .2,
    attack = .2
  }
}

Thuju.animations.death = {
  priority = 3,
  blocking = true,
  speed = .8,
  complete = function(self, owner)
    owner:die()
  end
}

return Thuju

