return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				htmldjango = { "djlint" },
				json = { "prettier" },
				yaml = { "yamlfmt" },
				yml = { "yamlfmt" },
				lua = { "stylua" },
				txt = { "prettier" },
				xml = { "xmlformat" },
				java = { "google-java-format" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				sh = { "shfmt" }, -- beautysh
				bash = { "shfmt" }, -- beautysh
				-- sql = { "sql_formatter" },
				python = { "ruff_format" },
			},

			formatters = {
				prettier = {
					prepend_args = { "--tab-width", "2" },
				},
				["clang-format"] = {
					prepend_args = { "--style={BreakBeforeBraces: Allman}" },
				},
				["google-java-format"] = {
					prepend_args = { "--aosp" }, -- Uses 4 spaces instead of 2
				},
				shfmt = {
					prepend_args = { "-i", "4", "-ci" }, -- indent 4 spaces, indent switch case
				},
				ruff_format = {
					command = "ruff",
					args = { "format", "--stdin-filename", "$FILENAME", "-" },
					extra_args = { "--extend-select", "I" },
					stdin = true,
				},
				xmlformat = {
					prepend_args = { "--blanks", "--selfclose", "--indent", "4" },
				},
			},

			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
