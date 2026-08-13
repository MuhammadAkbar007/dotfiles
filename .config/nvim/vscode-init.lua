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
-- Parity with snacks.bufdelete <leader>ww in the terminal config.
map("n", "<leader>ww", cmd("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
map("n", "<leader>sq", function()
	vim.fn.VSCodeNotify("workbench.action.files.save")
	vim.fn.VSCodeNotify("workbench.action.closeActiveEditor")
end, { desc = "Save and close" })

-- <C-w>q: close the split, but do nothing on the last one. vim's default would
-- quit the buffer; guard on visible-window count instead so a lone pane stays.
-- ponytail: winnr("$") tracks vscode-neovim's synced windows, which mirror the
-- visible editor groups. If it ever miscounts, drop the guard and let it always
-- closeEditorsAndGroup (vim-accurate: last pane closes the editor).
local function close_split()
	if vim.fn.winnr("$") > 1 then
		vim.fn.VSCodeNotify("workbench.action.closeEditorsAndGroup")
	end
end
map("n", "<C-w>q", close_split, { desc = "Close split (no-op if last)" })
map("n", "<C-w><C-q>", close_split, { desc = "Close split (no-op if last)" })
-- vim-maximizer <leader>sm parity: maximize the active group, toggle back.
map("n", "<leader>sm", cmd("workbench.action.toggleMaximizeEditorGroup"), { desc = "Maximize/restore split" })

-- Telescope -> VSCode pickers
map("n", "<leader>ff", cmd("workbench.action.quickOpen"), { desc = "Find files" })
map("n", "<leader>fr", cmd("workbench.action.openRecent"), { desc = "Recent files" })
-- fs opens Search empty; the view otherwise keeps its last query, so pass an
-- explicit empty query to clear it. fc seeds the word under cursor. Both pass
-- args explicitly instead of the global search.seedWithNearestWord, which would
-- seed fs too.
map("n", "<leader>fs", function()
	vim.fn.VSCodeNotify("workbench.action.findInFiles", { query = "" })
end, { desc = "Grep in cwd" })
map("n", "<leader>fc", function()
	vim.fn.VSCodeNotify("workbench.action.findInFiles", { query = vim.fn.expand("<cword>"), triggerSearch = true })
end, { desc = "Grep word under cursor" })
map("n", "<leader>ft", cmd("todo-tree.list"), { desc = "Find todos (needs Todo Tree ext)" })

-- nvim-tree -> explorer. Reveals the current file and focuses the tree.
-- Closing again is keybindings.json's job: once focus leaves the editor nvim
-- stops receiving keys, so the `space e` chord there handles toggle-off.
map("n", "<leader>e", cmd("workbench.files.action.showActiveFileInExplorer"), { desc = "Reveal file in explorer" })
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
