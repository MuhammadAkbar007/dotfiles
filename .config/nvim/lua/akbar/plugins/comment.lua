return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		local comment = require("Comment")
		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

		comment.setup({
			padding = true, -- Adds space between comment and text
			sticky = false, -- Keeps the cursor in place after commenting
			ignore = nil, ---@type string|fun():string|nil
			mappings = {
				basic = true, -- Enable basic mappings like gcc
				extra = true, -- Enable extra mappings like gco, gcO, gcA
			},
			toggler = {
				line = "gcc", -- Line-comment toggle key
				block = "gbc", -- Block-comment toggle key
			},
			opleader = {
				line = "gc", -- Line-comment key in visual mode
				block = "gb", -- Block-comment key in visual mode
			},
			extra = {
				above = "gcO", -- Comment above line
				below = "gco", -- Comment below line
				eol = "gcA", -- Comment at end of line
			},
			-- for commenting tsx, jsx, svelte, html files
			pre_hook = ts_context_commentstring.create_pre_hook(),
			post_hook = function() end, -- You can use a post-hook if necessary
		})

		-- Add custom mapping for gcI to comment at the start of the line and go to insert mode
		vim.keymap.set("n", "gcI", function()
			require("Comment.api").toggle.linewise.current() -- Comment the line
			vim.cmd("startinsert") -- Enter insert mode at the start
		end, { desc = "Comment at start of line and enter insert mode" })

		-- Disable auto commenting on new lines
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*",
			callback = function()
				vim.opt.formatoptions = vim.opt.formatoptions - "c" - "r" - "o"
			end,
		})
	end,
}
