return {
	"GCBallesteros/jupytext.nvim",
	lazy = false,
	config = function()
		require("jupytext").setup({
			style = "hydrogen",
			output_extension = "auto", -- Default extension. Don't change unless you know what you are doing
			force_ft = "ipynb", -- Default filetype. Don't change unless you know what you are doing
			custom_language_formatting = {},
		})
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = "*.ipynb",
			callback = function()
				vim.schedule(function()
					if vim.bo.filetype ~= "ipynb" then
						vim.bo.filetype = "ipynb"
					end
				end)
			end,
		})
	end,
	ft = { "ipynb" },
}
