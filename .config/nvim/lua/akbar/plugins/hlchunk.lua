return {
	"shellRaining/hlchunk.nvim",
	event = { "UIEnter" },
	config = function()
		require("hlchunk").setup({

			chunk = {
				enable = true,
				use_treesitter = true,
				chars = {
					horizontal_line = "─",
					vertical_line = "│",
					left_top = "╭",
					left_bottom = "╰",
					right_arrow = ">",
				},
				style = "#ffd700",
				duration = 1,
				delay = 1,
			},

			indent = {
				enable = true,
				use_treesitter = false,
				chars = {
					"│",
					"¦",
					"┆",
					"┊",
				},
				style = {
					vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
				},
			},

			-- blank = {
			-- 	enable = true,
			-- 	chars = {
			-- 		"․",
			-- 		"⁚",
			-- 		"⁖",
			-- 		"⁘",
			-- 		"⁙",
			-- 	},
			-- 	style = {
			-- 		"#666666",
			-- 		"#555555",
			-- 		"#444444",
			-- 	},
			-- },

			line_num = {
				enable = true,
				use_treesitter = true,
				style = "#ffd700",
			},
		})
	end,
}
