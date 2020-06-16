local logn2 = 0.69314
return {
	linear  = function(t) return t end,
	quad    = function(t) return t*t end,
	invquad = function(t) return 1 / (t*t) end,
	sine    = function(t) return math.sin(t * (math.pi / 2)) end,
	log     = function(t) return (math.log(t + 0.03)/logn2)/5 + 1 end,
	inout   = function(t)
		local tsq = t*t
		return tsq / (2.0 * (tsq - t) + 1)
	end	
}
