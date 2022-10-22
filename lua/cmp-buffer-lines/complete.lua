local api = vim.api
local leadings,lines = {},{}

local function addline(line, leading)
	line = line:gsub("^%s+", ""):gsub("%s+", " ")
	table.insert(lines, line)
	table.insert(leadings, leading)
end

-- This is used to use a literal string in regular expressions
local function escape(str)
	return str:gsub("%p", "%%%1")
end

-- Function to remove comments from a line
local function rmcomments(nmbr, line)
	-- Use tree-sitter if is installed
	if not (vim.fn.exists(":TSUpdate") >= 2) then
		local ts_utils = require "nvim-treesitter.ts_utils"
		local treesitter = require "vim.treesitter"

		local col = 1
		while (col < line:len()) do
			if line:find "%s" then
				col = col + 1
			else
				-- For some reason, tree-sitter uses 0-indexed line and column
				-- numbers.
				local tsnmbr, tscol = nmbr - 1, col - 1
				local node_length = ts_utils.node_length(
					treesitter.get_node_at_pos(buffer, tsnmbr, tscol))

				for _,v in pairs(treesitter.get_captures_at_pos(buffer, tsnmbr, tscol)) do
					if v["capture"] == "comment" then
						line = line:sub(col, col + node_length)
					end

					-- Go to the next node if possible, otherwise go to the next
					-- column
					col = v["capture"] and (col + node_length) + 1 or col + 1
				end
			end
		end
	else
		local comment_start,comment_ended
		-- More variables
		local comment
		local comment_string,comment_end = "",""

		for col = 1,line:len() do
			local syngroup = vim.fn.synIDattr(vim.fn.synID(nmbr, col, 1),
			"name"):gsub("^"..vim.o.filetype, "") -- Trim the file type

			-- If the syntax group is a single-line comment
			if (syngroup == "Comment" and not comment_start) or
				syngroup == "CommentL" then

				line = line:sub(1, col - 1)
				break
			elseif syngroup == "Comment" then
				comment = true
				-- If the syntax group is a multi-line comment
			elseif syngroup ~= "Comment" then
				if syngroup == "CommentStart" then
					if not comment_start then
						comment_start = col
					end

					if comment then
						comment_end = comment_end..line:sub(col, col)
					else
						comment_string = comment_string..line:sub(col, col)
					end
				elseif comment_start and syngroup ~= "CommentStart" then
					line = line:gsub(escape(comment_string)..".-"..
					escape(comment_end), "")
					comment_ended = true
					break
				end
			end
		end

		-- If the ending of a multi-line comment was not found
		if comment_start and not comment_ended then
			line = line:sub(1, comment_start - 1)
			comment_ended = true
		end

	end

	return line
end

local function generate(opts)
	-- Return nothing if the current file’s size (B) is greater than the
	-- user-defined `max_size` (kB)
	if vim.fn.getfsize(vim.fn.expand("%")) > (opts.max_size * 1000) then
		return
	end

	local buffer = api.nvim_get_current_buf()
	local indent = vim.o.expandtab and string.rep(" ", vim.o.tabstop) or "\t"
	leadings,lines = {},{}

	for nmbr,line in pairs(vim.fn.getline(1, api.nvim_buf_line_count(buffer))) do
		-- Exclude the current line
		if nmbr ~= api.nvim_win_get_cursor(api.nvim_get_current_win())[1] then
			-- Variables needed for the next `for` loop
			if not opts.comments then
				line = rmcomments(nmbr, line)
			end

			-- Strip trailing whitespace
			line = line:gsub("%s+$", "")

			-- If `words` is false, exclude lines that are just one word
			local words = not opts.words and line:match("^%s-%a+$")
				-- Exclude lines that are blank or just one word
				if not (line:match("^%s*$") or words) then
				-- If `leading_whitespace` is true, get the leading whitespace
				-- to concatenate it later
				local leading = ""
				if opts.leading_whitespace then
					leading = line:match("^%s+")
				end
				-- We cannot concatenate nil values
				if leading == nil then
					leading = ""
				end

				local max_indents = opts.max_indents
				if max_indents > 0 then
					if not line:match("^"..string.rep(indent, max_indents)) then
						addline(line, leading)
					end
				else
					addline(line, leading)
				end
			end
		end
	end

	-- Remove duplicates from the table
	local hash,uniq = {},{}
	for nmbr,line in pairs(lines) do
		if not hash[line] then
			-- Show leading whitespace in the label but not on
			-- selection/completion
			uniq[#uniq + 1] = { label = leadings[nmbr]..line, word = line }
			hash[line] = true
		end
	end

	return uniq
end

return function(_, params, callback)
	callback(generate(require "cmp-buffer-lines.options".validate(params)))
end
