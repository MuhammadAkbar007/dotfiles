return {
	"catppuccin/nvim", -- colorscheme catppuccin
	priority = 1000,
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			transparent_background = true, -- disables setting the background color.
			float = {
				transparent = true, -- enable transparent floating windows
				solid = true, -- use solid styling for floating windows, see |winborder|
			},
			term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { "italic" }, -- Change the style of comments
				conditionals = { "italic" },
			},
			color_overrides = {
				mocha = {
					peach = "#dae655",
					flamingo = "#ffb86c",
					mauve = "#bd93f9",
					blue = "#57bdd4",
					green = "#50fa7b",
					red = "#ff5555",
					maroon = "#f1fa8c",
					yellow = "#ffb86c",
				},
				latte = {
					green = "#50fa7b",
					-- blue = "#57bdd4",
				},
			},
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = true,
				mason = true,
				notifier = true,
				dap = true,
				dap_ui = true,
				navic = true,
				treesitter_context = true,
				render_markdown = true,
				dadbod_ui = true,
				which_key = true,
				snacks = {
					enabled = true,
				},
				telescope = {
					enabled = true,
				},
				illuminate = {
					enabled = false,
					lsp = false,
				},
				mini = true, -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
			},
			custom_highlights = function(colors)
				return {
					LineNr = { fg = colors.lavender },
				}
			end,
		})

		-- vim.cmd.colorscheme("catppuccin-latte")
		vim.cmd.colorscheme("catppuccin-mocha")
	end,
}
