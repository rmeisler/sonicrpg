
function string:wordwrap(maxlen)
    local result = ""
    local linecount = 0
    for _,s in ipairs({self:split()}) do
        if s:len() + linecount > maxlen then
            result = result .. "\n"
            linecount = 0
        end
        result = result .. s .. " "
        linecount = linecount + s:len() + 1
    end
    return result
end
