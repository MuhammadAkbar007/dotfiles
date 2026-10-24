return {
	-- https://github.com/sindrets/diffview.nvim
	-- Default keymaps inside a diffview (g? lists all):
	--   ]c / [c          next / previous change in file (built-in Neovim diff motion)
	--   <Tab> / <S-Tab>  next / previous changed file
	--   [F / ]F          first / last changed file
	--   ]x / [x          next / previous conflict (merge tool only)
	--   gf               open file in previous tab
	--   <leader>e        toggle file panel (overridden below, default is focus; matches nvim-tree toggle)
	--   <leader>b        toggle file panel
	"sindrets/diffview.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
	keys = {
		{ "<leader>gd", ":DiffviewOpen ", desc = "Diffview against a revision (type sha/range)" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview current file history" },
		{ "<leader>gh", ":DiffviewFileHistory<CR>", mode = "v", desc = "Diffview selected lines history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview repo history" },
		{ "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
	},
	opts = function()
		local actions = require("diffview.actions")
		local toggle = { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } }

		return {
			enhanced_diff_hl = true, -- better word-level highlight in changed lines
			keymaps = {
				view = { toggle },
				file_panel = { toggle },
				file_history_panel = { toggle },
			},
		}
	end,
}
