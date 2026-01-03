return {
	"hrsh7th/cmp-nvim-lsp",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{
			"SmiteshP/nvim-navbuddy",
			dependencies = {
				"SmiteshP/nvim-navic",
				"MunifTanjim/nui.nvim",
			},
			opts = { lsp = { auto_attach = true } },
		},
	},
	config = function()
		local navbuddy = require("nvim-navbuddy")
		local actions = require("nvim-navbuddy.actions")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local capabilities = cmp_nvim_lsp.default_capabilities()

		vim.lsp.config("eslint", {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end,
		})

		vim.lsp.config("clangd", {
			capabilities = capabilities,
		})

		vim.lsp.config("emmet_ls", {
			capabilities = capabilities,
		})

		vim.lsp.config("html", {
			capabilities = capabilities,
		})

		vim.lsp.config("lemminx", {
			capabilities = capabilities,
		})

		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
		})

		vim.lsp.config("markdown_oxide", {
			capabilities = capabilities,
		})

		vim.lsp.config("pyright", {
			capabilities = capabilities,
			root_dir = vim.fs.root(0, {
				"pyproject.toml",
				"pyrightconfig.json",
				".git",
			}),
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		vim.lsp.enable("pyright")

		vim.lsp.config("ruff_lsp", {
			capabilities = capabilities,
		})

		vim.lsp.config("tailwindcss", {
			capabilities = capabilities,
			settings = {
				tailwindCSS = {
					classFunctions = { "cva", "cx" },
				},
			},
		})

		vim.lsp.config("vtsls", {
			capabilities = capabilities,
		})

		vim.lsp.config("yamlls", {
			capabilities = capabilities,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				require("jdtls.jdtls_setup").setup({})
			end,
		})

		navbuddy.setup({
			use_breadcrumbs = false,
			window = {
				border = "rounded", --"single", "rounded", "double", "solid", "none"
				size = "60%", -- Or table format example: { height = "40%", width = "100%"}
				position = "50%", -- Or table format example: { row = "100%", col = "0%"}
				scrolloff = nil, -- scrolloff value within navbuddy window
				sections = {
					left = {
						size = "20%",
						border = nil, -- You can set border style for each section individually as well.
					},
					mid = {
						size = "40%",
						border = nil,
					},
					right = {
						-- No size option for right most section. It fills to remaining area.
						border = nil,
						preview = "leaf", -- Right section can show previews too.
						-- Options: "leaf", "always" or "never"
					},
				},
			},
			node_markers = {
				enabled = true,
				icons = {
					leaf = "  ",
					leaf_selected = " → ",
					branch = "  ",
				},
			},
			icons = {
				File = "󰈙 ",
				Module = " ",
				Namespace = "󰌗 ",
				Package = " ",
				Class = " ",
				Method = "󰆧 ",
				Property = " ",
				Field = " ",
				Constructor = " ",
				Enum = "󰕘 ",
				Interface = " ",
				Function = "󰊕 ",
				Variable = " ",
				Constant = "󰏿 ",
				String = " ",
				Number = "󰎠 ",
				Boolean = "◩ ",
				Array = "󰅪 ",
				Object = "󰅩 ",
				Key = "󰌋 ",
				Null = "󰟢 ",
				EnumMember = " ",
				Struct = "󰌗 ",
				Event = " ",
				Operator = "󰆕 ",
				TypeParameter = "󰊄 ",
			},
			use_default_mappings = true, -- If set to false, only mappings set
			-- by user are set. Else default
			-- mappings are used for keys
			-- that are not set by user
			mappings = {
				["<esc>"] = actions.close(), -- Close and cursor to original location
				["q"] = actions.close(),

				["j"] = actions.next_sibling(), -- down
				["k"] = actions.previous_sibling(), -- up

				["h"] = actions.parent(), -- Move to left panel
				["l"] = actions.children(), -- Move to right panel
				["0"] = actions.root(), -- Move to first panel

				["v"] = actions.visual_name(), -- Visual selection of name
				["V"] = actions.visual_scope(), -- Visual selection of scope

				["y"] = actions.yank_name(), -- Yank the name to system clipboard "+
				["Y"] = actions.yank_scope(), -- Yank the scope to system clipboard "+

				["i"] = actions.insert_name(), -- Insert at start of name
				["I"] = actions.insert_scope(), -- Insert at start of scope

				["a"] = actions.append_name(), -- Insert at end of name
				["A"] = actions.append_scope(), -- Insert at end of scope

				["r"] = actions.rename(), -- Rename currently focused symbol

				["d"] = actions.delete(), -- Delete scope

				["f"] = actions.fold_create(), -- Create fold of current scope
				["F"] = actions.fold_delete(), -- Delete fold of current scope

				["c"] = actions.comment(), -- Comment out current scope

				["<enter>"] = actions.select(), -- Goto selected symbol
				["o"] = actions.select(),

				["J"] = actions.move_down(), -- Move focused node down
				["K"] = actions.move_up(), -- Move focused node up

				["s"] = actions.toggle_preview(), -- Show preview of current node

				["<C-v>"] = actions.vsplit(), -- Open selected node in a vertical split
				["<C-s>"] = actions.hsplit(), -- Open selected node in a horizontal split

				["t"] = actions.telescope({ -- Fuzzy finder at current level.
					layout_config = { -- All options that can be
						height = 0.60, -- passed to telescope.nvim's
						width = 0.60, -- default can be passed here.
						prompt_position = "top",
						preview_width = 0.50,
					},
					layout_strategy = "horizontal",
				}),

				["g?"] = actions.help(), -- Open mappings help window
			},
			lsp = {
				auto_attach = true, -- If set to true, you don't need to manually use attach function
				preference = nil, -- list of lsp server names in order of preference
			},
			source_buffer = {
				follow_node = true, -- Keep the current node in focus on the source buffer
				highlight = true, -- Highlight the currently focused node
				reorient = "smart", -- "smart", "top", "mid" or "none"
				scrolloff = nil, -- scrolloff value when navbuddy is open
			},
			custom_hl_group = nil, -- "Visual" or any other hl group to use instead of inverted colors
		})
		vim.keymap.set("n", "<leader>nb", ":Navbuddy<CR>") -- open navbuddy
	end,
}
