local main = {}

main.default = {
	words = false,
	comments = false,
	leading_whitespace = true
}

function main.validate(params)
	local options = vim.tbl_deep_extend("keep", params.option, main.default)
	vim.validate {
		words = { options.words, "boolean" },
		comments = { options.comments, "boolean" },
		leading_whitespace = { options.leading_whitespace, "boolean" }
	}
	return options
end

return main
