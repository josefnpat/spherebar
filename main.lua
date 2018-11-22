function love.load()
  static_bg = love.graphics.newImage("custom_assets/static_bg.png")
  love.graphics.setBackgroundColor(0.16,0.16,0.16)

  spherebarlib = require"spherebar"

  health = spherebarlib.new{
    rearWaveColor =  {0.50,0.25,0.25},
    frontWaveColor = {1.00,0.25,0.25},
  }
  slime = spherebarlib.new{
    rearWaveColor =  {0.25,0.50,0.25},
    frontWaveColor = {0.25,1.00,0.25},
    waveSpeed = -32,
    foreground = love.graphics.newImage("custom_assets/foreground.png"),
    mask = love.graphics.newImage("custom_assets/mask.png"),
    background = love.graphics.newImage("custom_assets/background.png"),
  }
  mana = spherebarlib.new{
    rearWaveColor =  {0.25,0.25,0.50},
    frontWaveColor = {0.25,0.25,1.00},
  }

  offset = 0
end

function love.update(dt)
  offset = offset + dt/2
  mana:setWaveValue(math.sin(offset)/2+0.5)

  health:update(dt)
  slime:update(dt)
  mana:update(dt)
end

function love.draw()
  love.graphics.draw(static_bg)
  local w = love.graphics.getWidth()
  health:draw(w/4-health:getWidth()/2,(love.graphics.getHeight()-health:getHeight())/2)
  slime:draw(w/2-slime:getWidth()/2,(love.graphics.getHeight()-slime:getHeight())/2)
  mana:draw(w*3/4-mana:getWidth()/2,(love.graphics.getHeight()-mana:getHeight())/2)
end
