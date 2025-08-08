# Plugins

## Dressing => UI
> archived
```lua
return {
	"stevearc/dressing.nvim",
	event = "VeryLazy",
}
```
## Incline => to make floating filename on top-right
```lua
return {
	"b0o/incline.nvim",
	config = function()
		local helpers = require("incline.helpers")
		local devicons = require("nvim-web-devicons")

		require("incline").setup({
			window = {
				padding = 0,
				margin = { horizontal = 0 },
			},
			render = function(props)
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
				if filename == "" then
					filename = "[No Name]"
				end
				local ft_icon, ft_color = devicons.get_icon_color(filename)
				local modified = vim.bo[props.buf].modified
				return {
					ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
					" ",
					{ filename, gui = modified and "bold,italic" or "bold" },
					" ",
					guibg = "#44406e",
				}
			end,
		})
	end,
	event = "VeryLazy",
}
```

## Bufferline => to show buffers on top
```lua
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
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,

			numbers = "ordinal",
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
		},
	},

	vim.keymap.set("n", "<leader>ww", ":bd<CR>"),
}
```

## Colorscheme dracula
```lua
return {
	"Mofiqul/dracula.nvim", -- colorscheme Dracula
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("dracula").setup({
			colors = { -- customize dracula color palette
				bg = "#282A36",
				fg = "#F8F8F2",
				selection = "#44475A",
				comment = "#6272A4",
				red = "#FF5555",
				orange = "#FFB86C",
				yellow = "#F1FA8C",
				green = "#50fa7b",
				purple = "#BD93F9",
				cyan = "#8BE9FD",
				pink = "#FF79C6",
				bright_red = "#FF6E6E",
				bright_green = "#69FF94",
				bright_yellow = "#FFFFA5",
				bright_blue = "#D6ACFF",
				bright_magenta = "#827305",
				bright_cyan = "#A4FFFF",
				bright_white = "#FFFFFF",
				menu = "#21222C",
				visual = "#3E4452",
				gutter_fg = "#4B5263",
				nontext = "#3B4048",
				white = "#ABB2BF",
				black = "#191A21",
			},

			show_end_of_buffer = true, -- show the '~' characters after the end of buffers default false

			transparent_bg = true, -- use transparent background default false

			lualine_bg_color = "#44475a", -- set custom lualine background color default nil

			italic_comment = true, -- set italic comment default false

			overrides = { -- You can use overrides as table like this
				NonText = { fg = "white" }, -- set NonText fg to white
				NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
				Nothing = {}, -- clear highlight of Nothing
			},
		})

		vim.cmd([[colorscheme dracula-soft]])
	end,
}
```

## Colorscheme onedarkpro
```lua
return {
	"olimorris/onedarkpro.nvim", -- colorscheme onedarkpro
	priority = 1000, -- Ensure it loads first
	config = function()
		require("onedarkpro").setup({
			options = {
				transparency = true,
			},
		})
		vim.cmd("colorscheme onedark")
	end,
}
```

## Colorscheme tokyodark
```lua 
return {
	"tiagovla/tokyodark.nvim", -- colorscheme tokyodark.nvim
	opts = {
		transparent_background = true, -- set background to transparent
		gamma = 1.00, -- adjust the brightness of the theme
		styles = {
			comments = { italic = true }, -- style for comments
			keywords = { italic = true }, -- style for keywords
			identifiers = { italic = true }, -- style for identifiers
			functions = {}, -- style for functions
			variables = {}, -- style for variables
		},
		terminal_colors = true, -- enable terminal colors
	},
	config = function(_, opts)
		require("tokyodark").setup(opts) -- calling setup is optional
		vim.cmd([[colorscheme tokyodark]])
	end,
}```

## Buffer_manager
[Alternative](https://github.com/j-morano/buffer_manager.nvim)

```lua
return {
	"j-morano/buffer_manager.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local opts = { noremap = true }
		local map = vim.keymap.set

		require("buffer_manager").setup({
			select_menu_item_commands = {
				v = {
					key = "<C-v>",
					command = "vsplit",
				},
				h = {
					key = "<C-h>",
					command = "split",
				},
			},
			focus_alternate_buffer = true,
			order_buffers = "filename",
			short_file_names = true,
			short_term_names = true,
			loop_nav = true,
			highlight = "Normal:BufferManagerBorder",
			win_extra_options = {
				winhighlight = "Normal:BufferManagerNormal",
			},
			vim.api.nvim_set_hl(0, "BufferManagerBorder", { fg = "#ffd700" }),
			vim.api.nvim_set_hl(0, "BufferManagerNormal", { fg = "#B88339" }),
			vim.api.nvim_set_hl(0, "BufferManagerModified", { fg = "#FF0000" }),
		})

		-- Navigate buffers bypassing the menu
		local bmui = require("buffer_manager.ui")
		local keys = "1234567890"
		for i = 1, #keys do
			local key = keys:sub(i, i)
			map("n", string.format("<leader>%s", key), function()
				bmui.nav_file(i)
			end, opts)
		end

		-- Just the menu
		map({ "t", "n" }, "<leader><leader>", bmui.toggle_quick_menu, opts)

		-- Open menu and search
		map({ "t", "n" }, "<M-m>", function()
			bmui.toggle_quick_menu()
			-- wait for the menu to open
			vim.defer_fn(function()
				vim.fn.feedkeys("/")
			end, 50)
		end, opts)

		-- Next/Prev
		map("n", "<M-l>", bmui.nav_next, opts)
		map("n", "<M-h>", bmui.nav_prev, opts)
	end,

	-- Alternative
	-- https://github.com/dzfrias/arena.nvim
}
```

## Telescope
```lua
return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local trouble_telescope = require("trouble.sources.telescope")

		telescope.setup({
			defaults = {
				path_display = { "truncate " },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-t>"] = trouble_telescope.open,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		local keymap = vim.keymap -- for conciseness

		-- keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set(
			"n",
			"<leader>ff",
			"<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
			{ desc = "Fuzzy find files in cwd" }
		)
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find current saved buffers" })
	end,
}
```

## Toggleterm => floating terminal inside neovim
```lua
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			highlights = {
				FloatBorder = {
					guifg = "#555555", -- #b4befe
					guibg = "#1e1e2e", -- #1c1c2b
				},
			},
			float_opts = {
				border = "curved",
				winblend = 19, -- 25 | 0
				title_pos = "center",
			},
		})

		local Terminal = require("toggleterm.terminal").Terminal
		local float_term = nil

		local horiz_term = Terminal:new({
			direction = "horizontal",
			hidden = true,
			display_name = " Horizontal Terminal",
		})

		local vert_term = Terminal:new({
			direction = "vertical",
			hidden = true,
			display_name = " Vertical Terminal",
		})

		vim.keymap.set({ "n", "t" }, "<leader>th", function()
			horiz_term:toggle()
		end, { desc = "Toggle horizontal terminal" })

		vim.keymap.set({ "n", "t" }, "<leader>tv", function()
			vert_term:toggle()
		end, { desc = "Toggle vertical terminal" })

		vim.keymap.set({ "n", "t" }, "<leader>tf", function()
			if not float_term then
				local filename = vim.fn.expand("%:t")
				if filename == "" then
					filename = " Server 🚀 "
				end

				-- Get icon for the file (defaults to 🗎 if no match)
				local devicons = require("nvim-web-devicons")
				local icon, _ = devicons.get_icon(filename, nil, { default = true })

				float_term = require("toggleterm.terminal").Terminal:new({
					direction = "float",
					hidden = true,
					display_name = " ✨ " .. (icon or "") .. " " .. filename .. " ✨ ",
					cwd = vim.fn.getcwd(),
				})
			end

			float_term:toggle()
		end, { desc = "Toggle floating terminal (with icon)" })
	end,
}
```
