PhysicalEntity = class('PhysicalEntity', Entity)
PhysicalEntity._mt = {}

function PhysicalEntity._mt:__index(key)
  if key == 'velx' then
    return self._velocity.x
  elseif key == 'vely' then
    return self._velocity.y
  else
    local result = Entity._mt.__index(self, key)
    
    if result then
      return result
    elseif rawget(self, "_body") and self._body[key] then
      PhysicalEntity[key] = function(s, ...) return s._body[key](s._body, ...) end
      return PhysicalEntity[key]
    end
  end
end

function PhysicalEntity._mt:__newindex(key, value)
  if key == 'x' then
    self._pos.x = value
    if self._body then self._body:setX(value) end
  elseif key == 'y' then
    self._pos.y = value
    if self._body then self._body:setY(value) end
  elseif key == 'pos' then
    self._pos = value
    if self._body then self._body:setPosition(value.x, value.y) end
  elseif key == 'rotation' then
    self._rotation = value
    if self._body then self._body:setAngle(value) end
  elseif key == 'velx' then
    self._velocity.x = value
    local vx, vy = self._body:getLinearVelocity()
    if self._body then self._body:setLinearVelocity(value, vy) end
  elseif key == 'vely' then
    self._velocity.y = value
    local vx, vy = self._body:getLinearVelocity()
    if self._body then self._body:setLinearVelocity(vx, value) end
  elseif key == 'velocity' then
    self._velocity = value
    if self._body then self._body:setLinearVelocity(value.x, value.y) end
  else
    Entity._mt.__newindex(self, key, value)
  end
end

PhysicalEntity:enableAccessors()

function PhysicalEntity:initialize(x, y, type)
  Entity.initialize(self, x, y)
  self._velocity = Vector(0, 0)
  self._rotation = 0
  self.bodyType = type or "static"
  self:applyAccessors()
end

function PhysicalEntity:added()
  self:setupBody()
end

function PhysicalEntity:update(dt)
  if self._body then
    self._pos.x, self._pos.y = self._body:getPosition()
    self._velocity.x, self._velocity.y = self._body:getLinearVelocity()

    if self.noRotate then
      self._body:setAngle(0)
      self._rotation = 0
    else
      self._rotation = self._body:getAngle()
    end
  end
end

--[[ Format for the collided function
function PhysicalEntity:collided(other, fixture, otherFixture, contact)
  
end
]]

function PhysicalEntity:destroy()
  if self._body then
    self._body:destroy()
    self._body = nil
  end
end

PhysicalEntity.removed = PhysicalEntity.destroy

function PhysicalEntity:rotate(dr)
  self.rotation = self.rotation + dr
end

function PhysicalEntity:setupBody(type)
  if self._world then
    self._body = love.physics.newBody(self._world._world, self._pos.x, self._pos.y, type or self.bodyType)
    if self._rotation ~= 0 then self._body:setAngle(self._rotation) end
  end
end

function PhysicalEntity:addShape(shape, density)
  local fixture = love.physics.newFixture(self._body, shape, density)
  fixture:setUserData(self)
  return fixture
end
