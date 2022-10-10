local lines = {}

for _,line in pairs(vim.fn.getline(1, vim.api.nvim_buf_line_count(0))) do
	if not line:match("^%s*$") then
		table.insert(lines, { label = line:gsub("^\t+", "") })
	end
end

return lines
