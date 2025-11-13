return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"jdtls",
				"html",
				"cssls",
				"lua_ls",
				"emmet_ls",
				"pyright",
				"bashls",
				"jsonls",
				"lemminx",
				"yamlls",
				"vtsls", -- for ts, js, jsx, tsx
				"tailwindcss",
				"eslint",
				"clangd",
				"markdown_oxide",
			},
			automatic_installation = true, -- not the same as ensure_installed
			automatic_enable = {
				exclude = {
					"jdtls",
				},
			},
		},
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			"neovim/nvim-lspconfig",
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"java-debug-adapter",
				"java-test",
				"prettierd", -- prettier formatter
				"stylua", -- lua formatter
				"ruff",
				"eslint_d",
				"clang-format",
				"cpplint",
				"beautysh",
				"google-java-format",
				"curlylint",
				"htmlhint",
				"djlint",
				"yamlfmt",
				"xmlformatter",
			},
		},
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
}
