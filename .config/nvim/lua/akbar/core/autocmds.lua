vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*/templates/*.html" },
	callback = function()
		vim.bo.filetype = "htmldjango"
	end,
})
