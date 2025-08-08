return {
	"folke/trouble.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
	cmd = { "TroubleToggle", "Trouble" },
	opts = {
		use_diagnostic_signs = true,
		action_keys = {
			close = { "q", "<esc>" },
			cancel = "<c-e>",
		},
	},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
	},
}
