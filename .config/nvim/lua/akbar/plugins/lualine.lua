return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local helpers = require("akbar.core.lualine_helpers")
		local blank = helpers.blank
		local linter_info = helpers.linter_info
		local is_wide_enough = helpers.is_wide_enough
		local formatter_info = helpers.formatter_info
		local my_current_buffer = helpers.my_current_buffer
		local restore_session = helpers.restore_session

		local left_separator = ""
		local right_separator = ""

		vim.api.nvim_set_hl(0, "LualineBufferActive", { fg = "#000000", bg = "#B88339" })
		vim.api.nvim_set_hl(0, "LualineBufferInactive", { fg = "#B88339", bg = "#303030" })

		lualine.setup({
			options = {
				icons_enabled = true,
				theme = "powerline_dark", -- "catppuccin" or "auto"
				globalstatus = true,
				section_separators = { left = "", right = "" },
				component_separators = "", -- "|"
			},
			sections = {
				lualine_a = { { "mode", icon = " |", separator = { left = left_separator }, right_padding = 2 } },

				lualine_b = {
					-- linter
					{
						blank,
						cond = function()
							return linter_info() ~= "" and is_wide_enough(100)
						end,
					},
					{
						function()
							return "󰁨"
						end,
						color = { bg = "#fe640b", fg = "#000000", gui = "bold" },
						cond = function()
							return linter_info() ~= "" and is_wide_enough(100)
						end,
					},
					{
						linter_info,
						color = { bg = "#df8e1d", fg = "#000000", gui = "bold" },
						cond = function()
							return is_wide_enough(100)
						end,
					}, -- #8839ef

					-- formatter
					{
						blank,
						cond = function()
							return formatter_info() ~= "" and is_wide_enough(100)
						end,
					},
					{
						function()
							return "󱠓"
						end,
						color = { bg = "#fe640b", fg = "#000000", gui = "bold" },
						cond = function()
							return formatter_info() ~= "" and is_wide_enough(100)
						end,
					},
					{
						helpers.formatter_info,
						color = { bg = "#df8e1d", fg = "#000000", gui = "bold" },
						cond = function()
							return formatter_info() ~= "" and is_wide_enough(100)
						end,
					}, -- #1e66f5

					-- lsp
					{
						blank,
						cond = function()
							return #vim.lsp.get_clients({ bufnr = 0 }) > 0 and is_wide_enough(100)
						end,
					},
					{
						function()
							return "" -- 󰒍  
						end,
						color = { bg = "#fe640b", fg = "#000000", gui = "bold" },
						cond = function()
							return #vim.lsp.get_clients({ bufnr = 0 }) > 0
						end,
					},
					{
						"lsp_status",
						icon = "",
						color = { bg = "#df8e1d", fg = "#000000", gui = "bold" },
					},
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						separator = { right = "" },
						sections = { "error", "warn", "hint", "info" },
						symbols = { error = " ", warn = " ", hint = "󰠠 ", info = " " },
						colored = true,
						update_in_insert = false,
						always_visible = false,
					},
				},

				lualine_c = {
					"%=",
					{ my_current_buffer },
				},

				lualine_x = {
					{
						"swenv",
						icon = " |",
						color = { bg = "#4B8BBE", fg = "#000000", gui = "bold" },
						cond = function()
							return is_wide_enough(100)
						end,
						fmt = function(str)
							if str == "" then
								return ""
							end
							local env_name = str:match("([^/]+)$") or str
							return env_name
						end,
					},
					{
						function()
							return " "
						end,
						cond = function()
							return is_wide_enough(100)
						end,
					},

					-- git branch and diff
					{
						"branch",
						icon = " |",
						color = { bg = "#7287fd", fg = "black", gui = "bold" },
						cond = function()
							return is_wide_enough(100)
						end,
					},
					{
						"diff",
						separator = { right = "" },
						sections = { "added", "modified", "removed" },
						symbols = { added = " ", modified = "󰌇 ", removed = "󱛘 " },
						colored = true,
						update_in_insert = false,
						always_visible = false,
					},
					{
						function()
							return " "
						end,
						cond = function()
							return is_wide_enough(100)
						end,
					},
				},

				lualine_y = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ffd700" },
					},
					{
						function()
							return " "
						end,
						cond = function()
							return is_wide_enough(100) and lazy_status.has_updates()
						end,
					},
				},

				lualine_z = {
					{
						restore_session,
						separator = { right = right_separator },
						left_padding = 2,
						color = { bg = "#40a02b", fg = "#000000", gui = "bold" },
					},
				},
			},
		})
	end,
}
