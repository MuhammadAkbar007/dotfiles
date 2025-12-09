return {
	root_dir = function()
		return vim.fn.getcwd()
	end,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			completion = {
				callSnippet = "Replace",
			},
			workspace = {
				library = {
					"${3rd}/luv/library",
				},
			},
		},
	},
}
