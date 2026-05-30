return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescriptreact = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				txt = { "prettierd" },
				vue = { "prettierd" },
				json = { "prettierd" },
				yaml = { "yamlfmt" },
				yml = { "yamlfmt" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				sh = { "shfmt" }, -- beautysh
				bash = { "shfmt" }, -- beautysh
				htmldjango = { "djlint" },
				lua = { "stylua" },
				xml = { "xmlformat" },
				java = { "google-java-format" },
				python = { "ruff_format" },
				-- sql = { "sql_formatter" },
			},

			formatters = {
				prettier = {
					prepend_args = { "--tab-width", "4" },
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
