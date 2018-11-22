local current_folder = (...):gsub('%.[^%.]+$', '')

local spherebar = {}

spherebar.mask_shader = love.graphics.newShader[[
   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
         discard;
      }
      return vec4(1.0);
   }
]]

spherebar.background = love.graphics.newImage(current_folder.."/background.png")
spherebar.mask = love.graphics.newImage(current_folder.."/mask.png")
spherebar.foreground = love.graphics.newImage(current_folder.."/foreground.png")
spherebar.rearWaveColor = {0.5,0.5,0.5}
spherebar.frontWaveColor = {1.0,1.0,1.0}
spherebar.rearWaveOffset = 2
spherebar.waveAmplitude = 1/16
spherebar.waveCount = 3
spherebar.waveSpeed = math.pi*10
spherebar.waveValue = 0.5

function spherebar.new(init)
  init = init or {}
  local self = {}

  self.update = spherebar.update
  self.draw = spherebar.draw
  self.getWidth = spherebar.getWidth
  self.getHeight = spherebar.getHeight

  self._xoffset = 0

  self.setBackground = spherebar.setBackground
  self:setBackground(init.background or spherebar.background)

  self.setMask = spherebar.setMask
  self:setMask(init.mask or spherebar.mask)

  self.setForeground = spherebar.setForeground
  self:setForeground(init.foreground or spherebar.foreground)

  self.setRearWaveColor = spherebar.setRearWaveColor
  self:setRearWaveColor(init.rearWaveColor or spherebar.rearWaveColor)

  self.setFrontWaveColor = spherebar.setFrontWaveColor
  self:setFrontWaveColor(init.frontWaveColor or spherebar.frontWaveColor)

  self.setRearWaveOffset = spherebar.setRearWaveOffset
  self:setRearWaveOffset(init.rearWaveOffset or spherebar.rearWaveOffset)

  self.setWaveAmplitude = spherebar.setWaveAmplitude
  self:setWaveAmplitude(init.waveAmplitude or spherebar.waveAmplitude)

  self.setWaveCount = spherebar.setWaveCount
  self:setWaveCount(init.waveCount or spherebar.waveCount)

  self.setWaveSpeed = spherebar.setWaveSpeed
  self:setWaveSpeed(init.waveSpeed or spherebar.waveSpeed)

  self.setWaveValue = spherebar.setWaveValue
  self:setWaveValue(init.waveValue or spherebar.waveValue)

  self.rebuildCanvas = spherebar.rebuildCanvas

  return self
end

function spherebar:update(dt)
  self._xoffset = self._xoffset + dt*self._waveSpeed
end

function spherebar:draw(x,y)

  if self._canvasDirty then
    self:rebuildCanvas()
  end

  local old_color = {love.graphics.getColor()}
  love.graphics.setColor(1,1,1)
  love.graphics.draw(self._background,x,y)

  if self.stencil_mask_shader == nil then
    self.stencil_mask_shader = function()
      love.graphics.setShader(spherebar.mask_shader)
      love.graphics.draw(self._mask,x,y)
      love.graphics.setShader()
    end
  end
  love.graphics.stencil(self.stencil_mask_shader, "replace", 1)
  love.graphics.setStencilTest("greater", 0)

  local yoffset = self._foreground:getHeight()*(0.5-self._waveValue)
  local xoffset_rear = self._foreground:getWidth()/spherebar.waveCount/2
  for i = -1,0 do
    local xshift = i*self._foreground:getWidth()+self._xoffset%self._foreground:getWidth()
    love.graphics.setColor(self._rearWaveColor)
    love.graphics.draw(self._canvas,x+xshift+xoffset_rear,y-self._rearWaveOffset+yoffset)
    love.graphics.setColor(self._frontWaveColor)
    love.graphics.draw(self._canvas,x+xshift,y+yoffset)
  end

  love.graphics.setStencilTest()
  love.graphics.setColor(1,1,1)
  love.graphics.draw(self._foreground,x,y)
  love.graphics.setColor(old_color)
end

function spherebar:getWidth()
  return self._foreground:getWidth()
end

function spherebar:getHeight()
  return self._foreground:getHeight()
end

function spherebar:setBackground(image)
  self._background = image
end

function spherebar:setMask(image)
  self._mask = image
end

function spherebar:setForeground(image)
  self._canvasDirty = true
  self._foreground = image
end

function spherebar:setRearWaveColor(color)
  self._rearWaveColor = color
end

function spherebar:setFrontWaveColor(color)
  self._frontWaveColor = color
end

function spherebar:setRearWaveOffset(offset)
  self._rearWaveOffset = offset
end

function spherebar:setWaveAmplitude(scale)
  self._canvasDirty = true
  self._waveAmplitude = scale
end

function spherebar:setWaveCount(count)
  self._waveCount = count
end

function spherebar:setWaveSpeed(speed)
  self._waveSpeed = speed
end

function spherebar:setWaveValue(value)
  assert(value<=1)
  assert(value>=0)
  self._waveValue = value
end

function spherebar:rebuildCanvas()
  self._canvasDirty = false
  self._canvas = love.graphics.newCanvas(
    self._foreground:getWidth(),
    self._foreground:getHeight()*2)
  love.graphics.setCanvas(self._canvas)
  for i = 0,self._canvas:getWidth() do
    local offset = math.sin(i/self._canvas:getWidth()*2*math.pi*self._waveCount)
    love.graphics.line(
      i,self._canvas:getHeight()/4+offset*self._canvas:getHeight()/4*self._waveAmplitude,
      i,self._canvas:getHeight())
  end
  love.graphics.setCanvas()
end

return spherebar
