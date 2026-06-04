return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	opts = {
		options = {
			vim.cmd([[
			nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
			nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
			nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
			nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
			nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
			nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
			nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
			nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
			nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>

			nnoremap <silent><leader><Left> :BufferLineCyclePrev<CR>
			nnoremap <silent><leader><Right> :BufferLineCycleNext<CR>

			nnoremap <silent><TAB> :BufferLineCycleNext<CR>
			nnoremap <silent><S-TAB> :BufferLineCyclePrev<CR>
		]]),

			-- LSP Diagnostics Integration
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " "
					or level:match("warn") and " "
					or level:match("hint") and "󰠠 "
					or level:match("info") and " "
					or ""
				return " " .. icon .. count
			end,

			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},

			offsets = {
				{
					filetype = "NvimTree",
					text_align = "left",
					separator = true,
					highlight = "Directory",
					text = "📁 Akbar Ahmad ibn Akrom",
					-- text = function()
					--	return vim.fn.getcwd()
					-- end,
				},
			},

			numbers = "ordinal",
			left_trunc_marker = "󰩔 ", -- 
			right_trunc_marker = "󰋇 ", -- 
			always_show_bufferline = true,

			get_element_icon = function(element)
				if element.filetype == "runner-terminal" then
					return "󰑮"
				end
			end,
		},
	},

	-- vim.keymap.set("n", "<leader>ww", ":bd<CR>"),
}
