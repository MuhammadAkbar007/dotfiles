return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_reuse_buffer = 1
		vim.g.db_ui_save_location = vim.fn.getcwd() .. "/db_queries"
	end,
	keys = {
		{ "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle Database UI" },
		-- <Leader>W -> DBUI_SaveQuery
	},
}
