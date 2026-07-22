-- Init used ONLY by vscode-neovim inside VSCodium.
-- Loads options + keymaps from the real config, skips lazy.nvim/LSP entirely
-- (VSCode owns completion, diagnostics, file tree, fuzzy find).
-- ponytail: no plugin manager here. Add one only if a keymap needs a plugin
-- VSCode has no command for.

require("akbar.core.options")
require("akbar.core.keymaps")

local map = vim.keymap.set
local function cmd(name)
	return function()
		vim.fn.VSCodeNotify(name)
	end
end

-- Options VSCode renders itself; leaving them on double-draws the gutter.
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.cursorline = false

-- Buffers -> editor tabs
map("n", "<Tab>", cmd("workbench.action.nextEditor"), { desc = "Next editor" })
map("n", "<S-Tab>", cmd("workbench.action.previousEditor"), { desc = "Previous editor" })
map("n", "<leader><leader>", cmd("workbench.action.showAllEditors"), { desc = "Open editors" })

-- File ops
map({ "n", "i" }, "<C-s>", cmd("workbench.action.files.save"), { desc = "Save file" })
map("n", "<leader>q", cmd("workbench.action.closeActiveEditor"), { desc = "Close editor" })
map("n", "<leader>sq", function()
	vim.fn.VSCodeNotify("workbench.action.files.save")
	vim.fn.VSCodeNotify("workbench.action.closeActiveEditor")
end, { desc = "Save and close" })

-- Telescope -> VSCode pickers
map("n", "<leader>ff", cmd("workbench.action.quickOpen"), { desc = "Find files" })
map("n", "<leader>fr", cmd("workbench.action.openRecent"), { desc = "Recent files" })
map("n", "<leader>fs", cmd("workbench.action.findInFiles"), { desc = "Grep in cwd" })
map("n", "<leader>fc", cmd("workbench.action.findInFiles"), { desc = "Grep word under cursor" })
map("n", "<leader>ft", cmd("todo-tree.list"), { desc = "Find todos (needs Todo Tree ext)" })

-- nvim-tree -> explorer
map("n", "<leader>e", cmd("workbench.view.explorer"), { desc = "Toggle explorer" })
map("n", "<leader>tc", cmd("workbench.files.action.collapseExplorerFolders"), { desc = "Collapse explorer" })

-- LSP
map("n", "gr", cmd("editor.action.goToReferences"), { desc = "Show references" })
map("n", "gd", cmd("editor.action.revealDefinition"), { desc = "Go to definition" })
map("n", "gD", cmd("editor.action.revealDeclaration"), { desc = "Go to declaration" })
map("n", "gi", cmd("editor.action.goToImplementation"), { desc = "Go to implementation" })
map("n", "gt", cmd("editor.action.goToTypeDefinition"), { desc = "Go to type definition" })
map("n", "K", cmd("editor.action.showHover"), { desc = "Hover docs" })
map({ "n", "v" }, "<leader>ca", cmd("editor.action.quickFix"), { desc = "Code actions" })
map({ "n", "v" }, "<A-CR>", cmd("editor.action.quickFix"), { desc = "Code actions" })
map("n", "<leader>rn", cmd("editor.action.rename"), { desc = "Smart rename" })
map("n", "<leader>D", cmd("workbench.actions.view.problems"), { desc = "Buffer diagnostics" })
map("n", "<leader>d", cmd("editor.action.marker.next"), { desc = "Line diagnostics" })
map("n", "]d", cmd("editor.action.marker.next"), { desc = "Next diagnostic" })
map("n", "[d", cmd("editor.action.marker.prev"), { desc = "Previous diagnostic" })

-- Folding (nvim-ufo replacement)
map("n", "zR", cmd("editor.unfoldAll"), { desc = "Open all folds" })
map("n", "zM", cmd("editor.foldAll"), { desc = "Close all folds" })

-- lazygit
map("n", "<leader>lg", cmd("workbench.view.scm"), { desc = "Source control" })

-- Dead in VSCode: :Lazy, :Mason, LspRestart. Removed rather than stubbed.
pcall(vim.keymap.del, "n", "<leader>lw")
pcall(vim.keymap.del, "n", "<leader>mw")
