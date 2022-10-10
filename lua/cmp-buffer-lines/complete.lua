local hash,lines = {},{}
for _,line in pairs(vim.fn.getline(1, vim.api.nvim_buf_line_count(0))) do
	-- Ignore blank lines
	if not line:match("^%s*$") then
		-- `hash` is used to omit duplicate lines
		if not hash[line] then
			-- Show indentation level in the menu, but not when selecting
			table.insert(lines, { label = line, word = line:gsub("^%s+", "") })
			hash[line] = true
		end
	end
end
return lines
