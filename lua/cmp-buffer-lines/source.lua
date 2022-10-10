local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

function source.get_keyword_pattern()
	return ".*"
end

function source.complete(_, _, callback)
	callback(require "cmp-buffer-lines/complete")
end

return source
