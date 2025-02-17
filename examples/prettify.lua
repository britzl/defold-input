local M = {}


function M.prettify(t, indentation)
	indentation = indentation or ""
	local s = ""
	local keys = {}
	for k,v in pairs(t) do
		keys[#keys + 1] = k
	end
	for i=1,#keys do
		local k = keys[i]
		local v = t[k]
		local last = (i == #keys) and "" or ",\n"
		if type(v) == "table" then
			s = s .. ("%s%s = {\n%s\n}%s"):format(indentation, k, M.prettify(v, indentation .. "  "), last)
		else
			s = s .. ("%s%s = %s%s"):format(indentation, k, tostring(v), last)
		end
	end
	return s
end


return setmetatable(M, {
	__call = function(t, ...)
		return M.prettify(...)
	end
})