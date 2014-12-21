local Thuju = extend(Animation)
Thuju.code = 'thuju'

Thuju.scale = .35
Thuju.offsety = 64
Thuju.default = 'idle'
Thuju.states = {}

Thuju.states.spawn = {
  priority = 5,
  speed = .21
}

Thuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .21
}

Thuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Thuju.states.attack = {
  priority = 2,
  loop = true,
  speed = 1
}

Thuju.states.taunt = {
  priority = 3,
  speed = 1
}

Thuju.states.smash = {
  priority = 3,
  speed = 1
}

Thuju.states.death = {
  priority = 5,
  speed = .8
}

return Thuju
