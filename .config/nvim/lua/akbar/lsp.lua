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

local keymap = vim.keymap -- for conciseness

vim.api.nvim_create_autocmd("LspAttach", {
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
		keymap.set("n", "]d", function()
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

local severity = vim.diagnostic.severity

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
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[severity.ERROR] = " ",
			[severity.WARN] = " ",
			[severity.HINT] = "󰠠 ",
			[severity.INFO] = " ",
		},
	},
})
