return {
	-- https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "nvim-lua/plenary.nvim", branch = "master" },
	},
	build = "make tiktoken",
	opts = {
		window = {
			layout = "float", -- 'vertical', 'horizontal', 'float'
			width = 80, -- Fixed width in columns
			height = 20, -- Fixed height in rows
			border = "rounded", -- 'single', 'double', 'rounded', 'solid'
			zindex = 100, -- Ensure window stays on top
		},
		headers = {
			user = "👤 You",
			assistant = "🤖 Copilot",
			tool = "🔧 Tool",
		},
		separator = "━━",
		auto_fold = true, -- Automatically folds non-assistant messages
		auto_insert_mode = true, -- Enter insert mode when opening

		vim.keymap.set("n", "<leader>gc", "<cmd>CopilotChatToggle<cr>", { desc = "Toggle copilot chat window" }),
	},
}
