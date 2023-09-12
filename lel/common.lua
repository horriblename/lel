local M = {}

---returns an iterator that splits a string at sep
---@param str string The original string
---@param sep string? The separator pattern, defaults to "%s"
---@return fun():string, ...unknown
function M.split(str, sep)
	sep = sep or "%s"
	return string.gmatch(str, ("([^(%s)]+)"):format(sep))
end

return M
