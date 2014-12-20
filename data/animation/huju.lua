local Huju = extend(Animation)
Huju.code = 'huju'

Huju.scale = .5
Huju.default = 'idle'
Huju.states = {}

Huju.states.spawn = {
  priority = 5,
  speed = 1
}

Huju.states.idle = {
  priority = 1,
  loop = true,
  speed = .4
}

Huju.states.walk = {
  priority = 1,
  loop = true,
  speed = .4
}

Huju.states.attack = {
  priority = 2,
  speed = .8
}

Huju.animations.death = {
  priority = 5,
  speed = .8
}

return Huju
