local lines = {}
for _,line in pairs(vim.fn.getline(1, vim.api.nvim_buf_line_count(0))) do
	if not line:match("^%s*$") then
		line = line:gsub("^%s+", "")
		table.insert(lines, line)
	end
end

local hash,Lines = {},{}
for _,v in pairs(lines) do
	if not hash[v] then
		Lines[#Lines+1] = { label = v }
		hash[v] = true
	end
end

return Lines
