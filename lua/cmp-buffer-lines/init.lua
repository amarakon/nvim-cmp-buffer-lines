local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

source.complete = require "cmp-buffer-lines.complete"

return source
