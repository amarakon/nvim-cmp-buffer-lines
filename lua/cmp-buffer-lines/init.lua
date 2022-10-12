local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

function source.get_keyword_pattern()
	return ".*"
end

source.complete = require "cmp-buffer-lines.complete"

return source
