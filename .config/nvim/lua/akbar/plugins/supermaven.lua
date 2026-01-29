return {
	-- https://github.com/supermaven-inc/supermaven-nvim
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<M-l>",
				clear_suggestion = "<M-c>",
				accept_word = "<M-k>",
			},
			ignore_filetypes = { cpp = true }, -- or { "cpp", }
			color = {
				suggestion_color = "#6b7280",
				cterm = 244,
			},
			log_level = "info", -- set to "off" to disable logging completely
			disable_inline_completion = false, -- disables inline completion for use with cmp
			disable_keymaps = false, -- disables built in keymaps for more manual control
			condition = function()
				return false
			end,
		})
	end,
}
