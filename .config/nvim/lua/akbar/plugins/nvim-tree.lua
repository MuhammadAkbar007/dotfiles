return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	config = function()
		local nvimtree = require("nvim-tree")

		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
		vim.opt.termguicolors = true

		nvimtree.setup({
			sync_root_with_cwd = true,
			respect_buf_cwd = true,
			update_focused_file = {
				enable = true,
				update_root = false,
			},
			sort_by = "case_sensitive",
			view = {
				adaptive_size = true,
				relativenumber = true,
				float = {
					enable = true,
					open_win_config = function()
						-- Get the editor dimensions
						local screen_w = vim.opt.columns:get()
						local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()

						-- Calculate window size
						local window_w = math.min(50, math.floor(screen_w * 0.9))
						local window_h = math.min(100, math.floor(screen_h * 0.928))

						-- Calculate centered position
						-- local center_x = math.floor((screen_w - window_w) / 2)
						-- local center_y = math.floor((screen_h - window_h) / 2.5)

						return {
							border = "rounded",
							relative = "editor",
							width = window_w,
							height = window_h,
							row = 1,
							col = 1,
							-- row = center_y,
							-- col = center_x,
						}
					end,
					-- open_win_config = {
					-- 	relative = "editor",
					-- 	border = "rounded",
					-- 	width = 30,
					-- 	height = 30,
					-- 	row = 1,
					-- 	col = 1,
					-- },
				},
			},
			renderer = {
				indent_markers = {
					enable = true,
				},
				group_empty = false, -- compact middle empty folders
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},
			actions = {
				use_system_clipboard = true,
				open_file = {
					window_picker = {
						enable = false,
					},
					quit_on_open = true,
				},
			},
			filters = {
				dotfiles = false,
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "NvimTree",
			callback = function()
				vim.keymap.set("n", "q", ":NvimTreeClose<CR>", { buffer = true, silent = true }) -- Close NvimTree with 'q'
				vim.keymap.set("n", "<Esc>", ":NvimTreeClose<CR>", { buffer = true, silent = true }) --  -- Close NvimTree with 'Esc'
			end,
		})

		local function set_highlight(group, fg, bg)
			local command = string.format("highlight %s guifg=%s guibg=%s", group, fg or "NONE", bg or "NONE")
			vim.cmd(command)
		end

		set_highlight("NvimTreeFolderName", "#FFD700")
		set_highlight("NvimTreeFolderIcon", "#FFD700")
		set_highlight("NvimTreeOpenedFolderName", "#FFD700")
		set_highlight("NvimTreeEmptyFolderName", "#808080")
		set_highlight("NvimTreeIndentMarker", "#A9A9A9")

		vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggles file explorer nvimTree
		vim.keymap.set("n", "<leader>tc", ":NvimTreeCollapse<CR>") -- collapses file explorer nvimTree
	end,
}
