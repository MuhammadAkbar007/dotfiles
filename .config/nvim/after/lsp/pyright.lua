return {
	filetypes = { "python" },
	root_dir = require("lspconfig.util").root_pattern("manage.py", ".git", "pyrightconfig.json"),
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic", -- "off", "basic" or "strict" for tighter type checks
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}
