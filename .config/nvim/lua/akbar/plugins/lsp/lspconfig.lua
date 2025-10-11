return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
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
		local lspconfig = require("lspconfig")
		-- local lspconfig = vim.lsp.config
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local navbuddy = require("nvim-navbuddy")
		local actions = require("nvim-navbuddy.actions")

		local keymap = vim.keymap -- for conciseness

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
		keymap.set("n", "<leader>nb", ":Navbuddy<CR>") -- open navbuddy

		local function copy_diagnostic_to_clipboard() -- Custom Function to copy the diagnostic message under the cursor
			local line = vim.fn.line(".")
			local diagnostics = vim.diagnostic.get(0, { lnum = line - 1 }) -- Get diagnostics for the current line
			if #diagnostics > 0 then
				local messages = {}
				for _, diagnostic in ipairs(diagnostics) do
					table.insert(messages, diagnostic.message) -- Collect messages
				end

				vim.fn.setreg("+", table.concat(messages, "\n")) -- Use the "+" register for clipboard
				print("Copied diagnostic messages to clipboard")
			else
				print("No diagnostics found under cursor")
			end
		end

		local opts = vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				-- New mapping for Alt + Enter
				opts.desc = "See available code actions (Alt + Enter)"
				keymap.set({ "n", "v" }, "<A-CR>", vim.lsp.buf.code_action, opts) -- Alt + Enter

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>lrs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

				-- New mapping for copying diagnostic message
				opts.desc = "Copy diagnostic message to clipboard"
				keymap.set("n", "<leader>cd", copy_diagnostic_to_clipboard, opts)
			end,
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()

		vim.diagnostic.config({
			virtual_text = {
				enabled = true,
				source = "if_many", -- Show source if multiple sources
				prefix = "●", -- Could be '■', '▎', 'x', '●', etc.
				spacing = 4,
				format = function(diagnostic)
					return string.format("%s: %s", diagnostic.source, diagnostic.message)
				end,
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		mason_lspconfig.setup_handlers({
			["tailwindcss"] = function()
				lspconfig["tailwindcss"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = {
						"javascriptreact",
						"typescriptreact",
					},
				})
			end,

			["eslint"] = function()
				lspconfig["eslint"].setup({
					capabilities = capabilities,
					opts = opts,
				})
			end,

			["bashls"] = function()
				lspconfig["bashls"].setup({
					capabilities = capabilities,
					opts = opts,
				})
			end,

			["emmet_ls"] = function()
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = {
						"html",
						"htmldjango",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
				})
			end,

			["lua_ls"] = function()
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					opts = opts,
					root_dir = function()
						return vim.fn.getcwd()
					end,
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
							workspace = {
								library = {
									"${3rd}/luv/library",
								},
							},
						},
					},
				})
			end,

			["vtsls"] = function()
				lspconfig["vtsls"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = {
						"typescriptreact",
						"javascriptreact",
						"javascript",
					},
				})
			end,

			["html"] = function()
				lspconfig["html"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = { "html", "htmldjango" },
				})
			end,

			mason_lspconfig.setup_handlers({

				["clangd"] = function()
					lspconfig["clangd"].setup({
						capabilities = capabilities,
						opts = opts,
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--fallback-style=llvm",
						},
						filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
						root_dir = function(fname)
							return require("lspconfig.util").root_pattern(
								"compile_commands.json",
								"compile_flags.txt"
								-- ".git"
							)(fname) or vim.fn.getcwd()
						end,
					})
				end,
			}),

			["pyright"] = function()
				lspconfig["pyright"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = { "python" },
					root_dir = require("lspconfig.util").root_pattern("manage.py", ".git", "pyrightconfig.json"),
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic", -- "off", "basic" or "strict" for tighter type checks
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				})
			end,

			["yamlls"] = function()
				lspconfig["yamlls"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = { "yaml", "yml" },
				})
			end,

			["lemminx"] = function()
				lspconfig["lemminx"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = { "xml" },
				})
			end,

			["markdown_oxide"] = function()
				lspconfig["markdown_oxide"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = { "md", "markdown" },
				})
			end,
		})
	end,
}
