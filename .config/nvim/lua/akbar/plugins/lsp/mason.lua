return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	priority = 100,
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
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
			},
			-- auto-install configured servers (with lspconfig)
			automatic_installation = true, -- not the same as ensure_installed
		})

		mason_tool_installer.setup({
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
			},
		})
	end,
}
