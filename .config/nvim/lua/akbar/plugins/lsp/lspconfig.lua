return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

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
			function(server_name)
				if server_name ~= "jdtls" then
					lspconfig[server_name].setup({
						capabilities = capabilities,
						opts = opts,
					})
				end
			end,

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
					filetypes = { "html, htmldjango, jinja" },
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

			["jinja_lsp"] = function()
				lspconfig["jinja_lsp"].setup({
					capabilities = capabilities,
					opts = opts,
					filetypes = { "htmldjango", "jinja" },
				})
			end,
		})
	end,
}
