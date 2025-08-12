return {
	"hrsh7th/nvim-cmp",
	version = "*",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
		"roobert/tailwindcss-colorizer-cmp.nvim", -- tailwindcss
		"hrsh7th/cmp-cmdline",
		"rambhosale/cmp-bootstrap.nvim", -- bootstrap
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")
		local tailwind_cl_cmp = require("tailwindcss-colorizer-cmp")

		require("luasnip.loaders.from_vscode").lazy_load()

		tailwind_cl_cmp.setup({
			color_square_width = 3,
		})

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),

			sources = cmp.config.sources({
				{ name = "nvim_lsp_signature_help" },
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- snippets
				{ name = "cmp_bootstrap" },
				{ name = "buffer" }, -- text within current buffer
				{ name = "path" }, -- file system paths
			}),

			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
				}),
				fields = { "abbr", "kind", "menu" },
				expandable_indicator = true,
				tailwind_cl_cmp.formatter,
			},
		})

		-- for bootstrap
		cmp.setup.filetype({ "html", "jsx" }, {
			sources = cmp.config.sources({
				{ name = "nvim_lsp_signature_help" },
				{ name = "nvim_lsp" },
				{ name = "cmp_bootstrap" }, -- bootstrap completions
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),
		})

		-- Set up vim-dadbod
		cmp.setup.filetype({ "sql" }, {
			sources = {
				{ name = "vim-dadbod-completion" },
				{ name = "buffer" },
			},
		})

		-- for python
		cmp.setup.filetype("python", {
			mapping = {
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
			},
		})
	end,
}
