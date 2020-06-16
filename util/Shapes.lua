local Transform = require "util/Transform"

local Rect = class()

-- Make a bounding rect
function Rect.fromCircle(circle, buffer)
    local d = circle.r*2 + buffer
    return Rect(circle.transform, d, d)
end

function Rect.from(rect)
    return Rect(Transform.from(rect.transform), rect.w, rect.h)
end

function Rect:construct(transform, w, h)
    self.transform = transform
    self.w = w
    self.h = h
    self.hw = w/2
    self.hh = h/2
end

local Circle = class()

function Circle:construct(transform, r)
    self.transform = transform
    self.r = r
end

function Rect:isColliding(other)
    if other.istype(Circle) then
        return other:isColliding(self)
    elseif other.istype(Rect) then
        if other.transform.x + other.hw < self.transform.x - self.hw then
            return false
        elseif other.transform.x - other.hw > self.transform.x + self.hw then
            return false
        elseif other.transform.y + other.hh < self.transform.y - self.hh then
            return false
        elseif other.transform.y - other.hh > self.transform.y + self.hh then
            return false
        else
            return true
        end
    end

    return false
end

function Rect:resolve(other)
    if other.istype(Circle) then
        -- Distance between shapes
        dx = self.transform.x - other.transform.x
        dy = self.transform.y - other.transform.y
        d = math.sqrt(dx*dx + dy*dy)
        
        -- Normalized directions
        ndx = dx/d
        ndy = dy/d
        
        -- Penetration distance
        pdx = self.hw + other.r - d
        pdy = self.hh + other.r - d
        
        self.transform.x = self.transform.x + pdx * ndx
        self.transform.y = self.transform.y + pdy * ndy
    elseif other.istype(Rect) then
        -- Distance between shapes
        dx = self.transform.x - other.transform.x
        dy = self.transform.y - other.transform.y
        d = math.sqrt(dx*dx + dy*dy)
        
        -- Normalized directions
        ndx = dx/d
        ndy = dy/d
        
        -- Penetration distance
        pdx = self.hw + other.hw - d
        pdy = self.hh + other.hh - d
        
        self.transform.x = self.transform.x + pdx * ndx
        self.transform.y = self.transform.y + pdy * ndy
    end
end

function Circle:isColliding(other)
    if other.istype(Circle) then
        local dx = self.transform.x - other.transform.x
        local dy = self.transform.y - other.transform.y
        local radii = self.r + other.r
        return (dx*dx + dy*dy) < radii*radii
    elseif other.istype(Rect) then
        if other.transform.x + other.hw < self.transform.x - self.r then
            return false
        elseif other.transform.x - other.hw > self.transform.x + self.r then
            return false
        elseif other.transform.y + other.hh < self.transform.y - self.r then
            return false
        elseif other.transform.y - other.hh > self.transform.y + self.r then
            return false
        else
            return true
        end
    end

    return false
end

function Circle:resolve(other)
    if other.istype(Circle) then
        -- Distance between shapes
        dx = self.transform.x - other.transform.x
        dy = self.transform.y - other.transform.y
        d = math.sqrt(dx*dx + dy*dy)
        
        -- Normalized directions
        ndx = dx/d
        ndy = dy/d
        
        -- Penetration distance
        pd = self.r + other.r - d
        
        self.transform.x = self.transform.x + pd * ndx
        self.transform.y = self.transform.y + pd * ndy
    elseif other.istype(Rect) then
        -- Distance between shapes
        dx = self.transform.x - other.transform.x
        dy = self.transform.y - other.transform.y
        d = math.sqrt(dx*dx + dy*dy)
        
        -- Normalized directions
        ndx = dx/d
        ndy = dy/d
        
        -- Penetration distance
        pdx = self.r + other.hw - d
        pdy = self.r + other.hh - d
        
        self.transform.x = self.transform.x + pdx * ndx
        self.transform.y = self.transform.y + pdy * ndy
    end
end


return {Rect, Circle}