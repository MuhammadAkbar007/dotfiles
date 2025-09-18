return {
	"MeanderingProgrammer/render-markdown.nvim",
	event = "VeryLazy",
	opts = {},
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	config = function()
		require("render-markdown").setup({
			latex = { enabled = false },
			yaml = { enabled = false },
		})
	end,
}
