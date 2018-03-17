local M = {}


function M.prettify(t, indentation)
	indentation = indentation or ""
	local s = ""
	for k,v in pairs(t) do
		if type(v) == "table" then
			s = s .. ("%s%s = {\n%s},\n"):format(indentation, k, M.prettify(v, indentation .. "  "))
		else
			s = s .. ("%s%s = %s,\n"):format(indentation, k, tostring(v))
		end
	end
	return s
end


return setmetatable(M, {
	__call = function(t, ...)
		return M.prettify(...)
	end
})