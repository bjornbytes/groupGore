local ShadowDash = {}

ShadowDash.name = 'Shadow Dash'
ShadowDash.code = 'shadowdash'
ShadowDash.text = 'Shadow Dash'
ShadowDash.type = 'skill'

function ShadowDash:activate(shadowDash)
  shadowDash.cooldown = 0
end

function ShadowDash:update(shadowDash)
  
end

function ShadowDash:canFire(shadowDash)
  
end

function ShadowDash:fire(shadowDash)
  
end

function ShadowDash:value()
  return 0
end

return ShadowDash