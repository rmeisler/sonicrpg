
function string:trim()
    local i1,i2 = self:find('^%s*')
    if i2 >= i1 then self = self:sub(i2 + 1) end
    local i1,i2 = self:find('%s*$')
    if i2 >= i1 then self = self:sub(1, i1-1) end
    return self
end
