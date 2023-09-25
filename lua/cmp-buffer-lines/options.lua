local main = {}

main.default = {
	words = false,
	comments = false,
	line_numbers = false,
	line_number_separator = " ",
	leading_whitespace = true,
	max_indents = 0,
	max_size = 100
}

function main.validate(params)
	local options = vim.tbl_deep_extend("keep", params.option, main.default)
	vim.validate {
		words = { options.words, "boolean" },
		comments = { options.comments, "boolean" },
		line_numbers = { options.line_numbers, "boolean" },
		line_number_separator = { options.line_number_separator, "string" },
		leading_whitespace = { options.leading_whitespace, "boolean" },
		max_indents = { options.max_indents, "number" },
		max_size = { options.max_size, "number" }
	}
	return options
end

return main
