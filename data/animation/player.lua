local Muju = extend(Animation)
Muju.code = 'muju'

Muju.scale = .65
Muju.offsety = Player.height / 2
Muju.default = 'idle'
Muju.states = {}

Muju.states.idle = {
  priority = 1,
  loop = true,
  speed = .4,
  mix = {
    walk = .2,
    summon = .1,
    death = .2
  }
}

Muju.states.walk = {
  priority = 1,
  loop = true,
  speed = 1,
  mix = {
    idle = .1,
    summon = .1,
    death = .2
  }
}

Muju.states.summon = {
  priority = 2,
  blocking = true,
  speed = 1.85,
  mix = {
    walk = .2,
    idle = .2
  }
}

Muju.states.death = {
  priority = 3,
  blocking = true,
  mix = {
    resurrect = .2
  }
}

Muju.states.resurrect = {
  priority = 3,
  blocking = true,
  speed = 2
}

return Muju
