local map = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "

-- General keymaps
map("n", "<Tab>", ":bn<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bp<CR>", { desc = "Previous buffer" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
-- map("i", "kj", "<ESC>", { desc = "Exit insert mode" })
map("n", "vv", "gg0vG$", { desc = "Select whole file" })

-- File operations
map("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<C-o>:w<CR><ESC>", { desc = "Save file" })
-- map("n", "<leader>s", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>sq", ":wq<CR>", { desc = "Save and quit" })

-- Plugin windows
map("n", "<leader>lw", ":Lazy<CR>", { desc = "Open Lazy window" })
map("n", "<leader>mw", ":Mason<CR>", { desc = "Open Mason window" })

-- Utility
map("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<leader>dm", ":delmarks!<CR>", { desc = "Delete all marks" })

-- File system operations
map("n", "<leader>o", ":silent !nautilus %:p:h &<CR>", { desc = "Open directory in file manager" })
map("n", "<leader>xdg", ":silent !xdg-open %:p &<CR>", { desc = "Open current file with default app" })

-- Number increment/decrement
map("n", "<leader>+", "<C-a>", { desc = "Increment number" })
map("n", "<leader>_", "<C-x>", { desc = "Decrement number" })

-- Text manipulation
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "J", "mzJ`z", { desc = "Join lines preserving cursor position" })

-- Search navigation
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Clipboard operations
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })
map("v", "<leader>d", '"_d', { desc = "Delete selection to void register" })
map("n", "<leader>dw", '"_dw', { desc = "Delete word to void register" })
map("n", "<leader>dd", '"_dd', { desc = "Delete line to void register" })
map("n", "<leader>d$", '"_d$', { desc = "Delete to end of line to void register" })

-- Text replacement
map(
	"n",
	"<leader>rpa",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace all occurrences of current word" }
)

map(
	"n",
	"<leader>rp",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gcI<Left><Left><Left><Left>]],
	{ desc = "Replace all occurrences of current word with confirmation" }
)
