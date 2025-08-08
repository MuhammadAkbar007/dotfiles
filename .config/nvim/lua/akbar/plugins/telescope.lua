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
		local make_entry = require("telescope.make_entry")
		local entry_display = require("telescope.pickers.entry_display")
		local utils = require("telescope.utils")
		local strings = require("plenary.strings")
		local devicons = require("nvim-web-devicons")

		local function get_path_and_tail(filename)
			local bufname_tail = utils.path_tail(filename)
			local path_without_tail = strings.truncate(filename, #filename - #bufname_tail, "")

			-- Simple truncation approach instead of using transform_path
			local max_path_length = 30 -- Adjust this value as needed
			local path_to_display = path_without_tail
			if #path_without_tail > max_path_length then
				path_to_display = "..." .. path_without_tail:sub(-max_path_length)
			end

			return bufname_tail, path_to_display
		end

		local function custom_entry_maker(opts)
			opts = opts or {}
			local def_icon = devicons.get_icon("fname", { default = true })
			local iconwidth = strings.strdisplaywidth(def_icon)

			local entry_make = make_entry.gen_from_file(opts)

			return function(line)
				local entry = entry_make(line)
				local displayer = entry_display.create({
					separator = "",
					items = {
						{ width = iconwidth },
						{ width = nil },
						{ remaining = true },
					},
				})

				entry.display = function(et)
					local tail_raw, path_to_display = get_path_and_tail(et.value)
					local tail = tail_raw .. " "
					local icon, iconhl = utils.get_devicons(tail_raw)

					return displayer({
						{ icon, iconhl },
						tail,
						{ path_to_display, "TelescopeResultsComment" },
					})
				end

				return entry
			end
		end

		telescope.setup({
			defaults = {
				entry_maker = custom_entry_maker(),
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-e>"] = actions.preview_scrolling_down, -- Scroll preview window down by one line
						["<C-y>"] = actions.preview_scrolling_up, -- Scroll preview window up by one line
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-t>"] = trouble_telescope.open,
					},
				},
			},
			pickers = {
				find_files = {
					entry_maker = custom_entry_maker(),
				},
				oldfiles = {
					entry_maker = custom_entry_maker(),
				},
				-- live_grep = {
				-- 	entry_maker = custom_entry_maker(),
				-- },
				-- grep_string = {
				-- 	entry_maker = custom_entry_maker(),
				-- },
				buffers = {
					sort_mru = true,
					sort_lastused = true,
					-- Custom entry maker for buffers with indicators
					entry_maker = function(entry)
						local displayer = entry_display.create({
							separator = " ",
							items = {
								{ width = 3 }, -- Buffer number
								{ width = 1 }, -- Icon
								{ width = nil }, -- Filename
								{ remaining = true }, -- Path
							},
						})

						local bufname = entry.info.name ~= "" and entry.info.name or "[No Name]"
						local bufname_tail, path_to_display = get_path_and_tail(bufname)
						local icon, iconhl = utils.get_devicons(bufname_tail)

						entry.filename = entry.info.name -- This is crucial for preview
						entry.value = entry.info.name -- This is also needed for some operations
						entry.path = entry.info.name -- Ensure this is set for preview

						entry.display = function(_)
							return displayer({
								{ entry.bufnr, "TelescopeResultsNumber" },
								{ icon, iconhl },
								bufname_tail,
								{ path_to_display, "TelescopeResultsComment" },
							})
						end

						entry.ordinal = entry.bufnr .. " : " .. bufname

						return entry
					end,
				},
			},
		})

		telescope.load_extension("fzf")

		local keymap = vim.keymap -- for conciseness

		-- keymap.set(
		-- 	"n",
		-- 	"<leader>ff",
		-- 	"<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
		-- 	{ desc = "Fuzzy find files in cwd with hidden files" }
		-- )
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<leader><leader>", "<cmd>Telescope buffers<cr>", { desc = "Find current saved buffers" })
	end,
}
