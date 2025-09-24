return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")

		local helpers = require("akbar.core.lualine_helpers")
		local linter_info = helpers.linter_info
		local is_wide_enough = helpers.is_wide_enough
		local formatter_info = helpers.formatter_info
		local my_current_buffer = helpers.my_current_buffer
		local restore_session = helpers.restore_session

		local colors = require("catppuccin.palettes").get_palette("mocha")

		local function separator()
			return {
				function()
					return "│ "
				end,
				color = { fg = colors.surface0, bg = "NONE", gui = "bold" },
				padding = { left = 0, right = 0 },
			}
		end

		lualine.setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				globalstatus = true,
				section_separators = "",
				component_separators = "",
				disabled_filetypes = { statusline = { "snacks_dashboard" } },
			},
			sections = {
				lualine_a = {
					{
						"mode",
						color = function()
							local mode = vim.fn.mode()
							local cls = require("catppuccin.palettes").get_palette("mocha")

							local mode_colors = {
								n = cls.blue,
								i = cls.green,
								v = cls.mauve,
								V = cls.mauve,
								[""] = cls.mauve, -- Visual block
								c = cls.peach,
								R = cls.red,
								t = cls.flamingo,
							}

							return { fg = mode_colors[mode] or colors.text, bg = "none", gui = "bold" }
						end,
						padding = { left = 1, right = 1 },
					},
					separator(),
				},

				lualine_b = {
					{
						my_current_buffer,
						color = { fg = colors.blue, bg = "none" },
						padding = { left = 1, right = 1 },
					},
					separator(),
				},

				lualine_c = {
					-- Linter
					{
						linter_info,
						icon = "󰁨 ",
						color = { fg = colors.peach, bg = "none", gui = "bold" },
						cond = function()
							return linter_info() ~= "" and is_wide_enough(100)
						end,
						padding = { left = 1, right = 1 },
					},
					vim.tbl_extend("force", separator(), {
						cond = function()
							return linter_info() ~= "" and is_wide_enough(100)
						end,
					}),
					-- Formatter
					{
						formatter_info,
						icon = "󱠓 ",
						color = { fg = colors.yellow, bg = "none", gui = "bold" },
						cond = function()
							return formatter_info() ~= "" and is_wide_enough(100)
						end,
						padding = { left = 0, right = 1 },
					},
					vim.tbl_extend("force", separator(), {
						cond = function()
							return formatter_info() ~= "" and is_wide_enough(100)
						end,
					}),

					-- LSP
					{
						"lsp_status",
						icon = " ",
						color = { fg = colors.green, bg = "none", gui = "bold" },
						cond = function()
							return #vim.lsp.get_clients({ bufnr = 0 }) > 0
						end,
						padding = { left = 1, right = 1 },
					},

					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn", "info", "hint" },
						symbols = {
							error = " ",
							warn = " ",
							hint = "󰠠 ",
							info = " ",
						},
						diagnostics_color = {
							error = { fg = colors.red, bg = "none", gui = "bold" },
							warn = { fg = colors.yellow, bg = "none", gui = "bold" },
							info = { fg = colors.blue, bg = "none", gui = "bold" },
							hint = { fg = colors.teal, bg = "none", gui = "bold" },
						},
						colored = true,
						update_in_insert = false,
						always_visible = false,
						padding = { left = 0, right = 1 },
					},
				},

				lualine_x = {
					{
						"swenv",
						icon = " ",
						color = { fg = colors.blue, bg = "none", gui = "bold" },
						cond = function()
							return is_wide_enough(100)
						end,
						fmt = function(str)
							if str == "" then
								return ""
							end
							return str:match("([^/]+)$") or str
						end,
						padding = { left = 1, right = 1 },
					},
					separator(),
					{
						"branch",
						icon = "",
						color = { fg = colors.lavender, bg = "none", gui = "bold" },
						cond = function()
							return is_wide_enough(100)
						end,
						padding = { left = 1, right = 1 },
					},
					{
						"diff",
						sections = { "added", "modified", "removed" },
						symbols = { added = " ", modified = "󰌇 ", removed = "󱛘 " },
						diff_color = {
							added = { fg = colors.teal, bg = "none", gui = "bold" },
							modified = { fg = colors.yellow, bg = "none", gui = "bold" },
							removed = { fg = colors.red, bg = "none", gui = "bold" },
						},
						padding = { left = 0, right = 1 },
					},
				},

				lualine_y = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = colors.peach },
						padding = { left = 1, right = 1 },
					},
				},

				lualine_z = {
					separator(),
					{
						restore_session,
						color = { fg = colors.green, bg = "none", gui = "bold" },
						padding = { left = 1, right = 1 },
					},
				},
			},
		})
	end,
}
