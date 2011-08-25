-- This is for love.physics. For custom physics, see Physical.

PhysicalWorld = class('PhysicalWorld', World)
PhysicalWorld._mt = {}

function PhysicalWorld._mt:__index(key)
  local result = World._mt.__index(self, key)
  
  if result then
    return result
  elseif self._world[key] then
    self[key] = function(self, ...) return self._world[key](self._world, ...) end
    return self[key]
  end
end 

PhysicalWorld:enableAccessors()

function PhysicalWorld:initialize(...)
  World.initialize(self)
  self.physicsActive = true
  self._world = love.physics.newWorld(...)
  self._world:setCallbacks(PhysicalWorld._onCollide)
  self:applyAccessors()
end

function PhysicalWorld:update(dt)
  if self.physicsActive then
    if dt > .03 then
      local current = dt
      
      while current > .03 do
        current = current - .03
        self._world:update(.03)
      end
      
      self._world:update(current)
    else
      self._world:update(dt)
    end
  end
  
  World.update(self, dt)
end

function PhysicalWorld:wakeAll()
  for v in self._updates:getIterator() do
    if instanceOf(PhysicalEntity, v) and v._body then
      v._body:wakeUp()
    end
  end
end

function PhysicalWorld:sleepAll()
  for v in self._updates:getIterator() do
    if instanceOf(PhysicalEntity, v) and v._body then
      v._body:putToSleep()
    end
  end
end

function PhysicalWorld._onCollide(a, b, collision)
  a.self:collided(a.shape, b.self, b.shape, collision)
end
