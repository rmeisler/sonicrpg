local Lazy = function(fun, obj, field)
	return setmetatable({isLazy = true}, {__index = function(t,k)
			local inst = obj and fun(obj) or fun()
			return field and inst[field][k] or inst[k]
		end
	})
end


return Lazy
