
function table.count(t)
    local num = 0
    for _ in pairs(t) do
        num = num + 1
    end
    return num
end
