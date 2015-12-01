local signatures = {}

signatures.client = {
  [app.net.messages.join] = {{'username', 'string'}, important = true},
  [app.net.messages.leave] = {important = true},
  [app.net.messages.class] = {{'class', '4bits'}, {'team', '1bit'}, important = true},
  [app.net.messages.input] = {
    {'tick', '16bits'},
    {'w', 'bool'}, {'a', 'bool'}, {'s', 'bool'}, {'d', 'bool'},
    {'x', '12bits'}, {'y', '12bits'}, {'l', 'bool'}, {'r', 'bool'},
    {'slot', '3bits'}, {'reload', 'bool'},
    delta = {{'w', 'a', 's', 'd'}, {'x', 'y'}, 'l', 'r', 'slot', 'reload'}
  },
  [app.net.messages.chat] = {{'message', 'string'}, important = true}
}

signatures.server = {
  [app.net.events.join] = {{'id', '4bits'}, {'username', 'string'}, important = true},
  [app.net.events.leave] = {{'id', '4bits'}, {'reason', 'string'}, important = true},
  [app.net.events.class] = {{'id', '4bits'}, {'class', '4bits'}, {'team', '1bit'}, important = true},
  [app.net.events.sync] = {
    {'id', '4bits'},
    {'tick', '16bits'},
    {'ack', '16bits'},
    {'x', '16bits'}, {'y', '16bits'}, {'z', '8bits'},
    {'angle', '10bits'},
    {'health', '10bits'}, {'shield', '10bits'},
    {'weapon', '3bits'}, {'skill', '3bits'},
    delta = {'x', 'y', 'z', 'angle', 'health', 'shield', 'weapon', 'skill'}
  },
  [app.net.events.fire] = {
    {'id', '4bits'}, {'slot', '3bits'}, {'mx', '12bits'}, {'my', '12bits'},
    delta = {{'mx', 'my'}}
  },
  [app.net.events.damage] = {{'id', '4bits'}, {'amount', 'string'}, {'from', '4bits'}},
  [app.net.events.dead] = {{'id', '4bits'}, {'kill', '4bits'}, {'assists', {{'id', '4bits'}}}, important = true},
  [app.net.events.spawn] = {{'id', '4bits'}, important = true},
  [app.net.events.chat] = {{'message', 'string'}, important = true},
  [app.net.events.prop] = {{'id', '16bits'}, {'x', '16bits'}, {'y', '16bits'}},
  [app.net.messages.join] = {{'id', '4bits'}, important = true},
  [app.net.messages.snapshot] = {
    {'tick', '16bits'},
    {'map', 'string'},
    {'players', {{'id', '4bits'}, {'username', 'string'}, {'class', '4bits'}, {'team', '1bit'}}},
    important = true
  }
}

return signatures
