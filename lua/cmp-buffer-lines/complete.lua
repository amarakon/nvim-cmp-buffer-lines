-- This is used to use a literal string in regular expressions
local function escape(str)
	return str:gsub("%p", "%%%1")
end

local function generate(opts)
	local leadings,lines = {},{}
	for nmbr,line in pairs(vim.fn.getline(1, vim.api.nvim_buf_line_count(0))) do
		-- Exclude the current line
		if nmbr ~= vim.api.nvim_win_get_cursor(0)[1] then
			-- Variables needed for the next `for` loop
			local comment_start,comment_ended
			if not opts.comments then
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
			end

			-- If the ending of a multi-line comment was not found
			if comment_start and not comment_ended then
				line = line:sub(1, comment_start - 1)
				comment_ended = true
			end

			-- Strip trailing whitespace
			line = line:gsub("%s+$", "")

			-- If `words` is false, exclude lines that are just one word
			local words = not opts.words and line:match("^%s-%a+$")
			-- Exclude lines that are just comments
			if (not comment_start or comment_ended) and
				-- Exclude lines that are blank or just one word
				not (line:match("^%s*$") or words) then

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

				-- Replace multiple whitespace with one space
				lines[nmbr] = line:gsub("^%s+", ""):gsub("%s+", " ")
				leadings[nmbr] = leading
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
