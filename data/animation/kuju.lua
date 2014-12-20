local Kuju = extend(Animation)
Kuju.code = 'kuju'

Kuju.scale = .35
Kuju.offsety = 64
Kuju.default = 'idle'
Kuju.states = {}

Kuju.states.spawn = {
  priority = 5,
  speed = .21
}

Kuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .21
}

Kuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Kuju.states.attack = {
  priority = 2,
  speed = 1
}

Kuju.states.taunt = {
  priority = 3,
  speed = 1
}

Kuju.states.smash = {
  priority = 3,
  speed = 1
}

Kuju.states.death = {
  priority = 5,
  speed = .8
}

return Kuju
