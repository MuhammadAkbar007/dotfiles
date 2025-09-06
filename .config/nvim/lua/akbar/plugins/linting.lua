return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "ruff" },
			c = { "cpplint" },
			cpp = { "cpplint" },
			bash = { "shellcheck" },
			zsh = { "shellcheck" },
			shell = { "shellcheck" },
			html = { "htmlhint" },
			htmldjango = { "djlint", "curlylint" },
		}

		lint.linters.cpplint.args = { "--filter=-whitespace/braces" }

		lint.linters.shellcheck.args = {
			"--shell=zsh", -- shellcheck does not fully support zsh but this helps a little
			"--exclude=SC1090,SC1091", -- examples of ignoring common warnings
		}

		lint.linters.ruff.args = {
			"--select=ALL",
			"--ignore=E501",
		}

		lint.linters.djlint.args = { "--quiet" }

		lint.linters.curlylint.args = { "--stdin-filename", "$FILENAME", "-" }

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>li", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		-- Add this to your keymap section in the nvim-lint config
		vim.keymap.set("n", "<leader>rf", function()
			local filename = vim.api.nvim_buf_get_name(0)
			if filename == "" then
				vim.notify("No file to fix", vim.log.levels.WARN)
				return
			end

			-- Run ruff check --fix on the current file
			local cmd = string.format("ruff check --fix %s", vim.fn.shellescape(filename))
			local result = vim.fn.system(cmd)

			if vim.v.shell_error == 0 then
				-- Reload the buffer to show changes
				vim.cmd("edit!")
				-- Re-run linting to update diagnostics
				require("lint").try_lint()
				vim.notify("Ruff: Fixed auto-fixable problems", vim.log.levels.INFO)
			else
				vim.notify("Ruff fix failed: " .. result, vim.log.levels.ERROR)
			end
		end, { desc = "Ruff: Fix all auto-fixable problems" })
	end,
}
