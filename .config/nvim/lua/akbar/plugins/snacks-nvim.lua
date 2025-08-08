return {
	-- https://github.com/folke/snacks.nvim
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- bufdelete = { enabled = true },

		scratch = { enabled = true, ft = "markdown", cwd = true, root = vim.fn.getcwd() .. "/scratch" },

		words = { enabled = true },

		notify = { enabled = true },

		notifier = { enabled = true, timeout = 3000 },

		input = { enabled = true, win = { relative = "cursor" } },

		image = {
			enabled = true,
			force = false,
			formats = {
				"png",
				"jpg",
				"jpeg",
				"svg",
				"gif",
				"bmp",
				"webp",
				"tiff",
				"heic",
				"avif",
				"mp4",
				"mov",
				"avi",
				"mkv",
				"webm",
				"pdf",
			},
			img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
			cache = vim.fn.stdpath("cache") .. "/snacks/image",
			icons = { math = "󰪚 ", chart = "󰄧 ", image = " " },
		},

		statuscolumn = {
			enabled = true,
			left = { "mark", "sign" }, -- priority of signs on the left (high to low)
			right = { "fold", "git" }, -- priority of signs on the right (high to low)
			folds = {
				open = true, -- show open fold icons
				git_hl = true, -- use Git Signs hl for fold icons
			},
			git = {
				patterns = { "GitSign", "MiniDiffSign" },
			},
			refresh = 50, -- refresh at most every 50ms
		},

		styles = {
			notification = {
				wo = { wrap = true }, -- Wrap notifications
			},
		},
	},
	keys = {
		---@module "snacks"
		{
			"<leader>.",
			function()
				-- open a scratch buffer
				Snacks.scratch()

				-- add scratch/ folder to .gitignore if exists
				local cwd = vim.fn.getcwd()
				local gitignore = cwd .. "/.gitignore"
				local entry = "scratch/"
				if vim.fn.filereadable(gitignore) == 1 then
					local lines = vim.fn.readfile(gitignore)
					for _, line in ipairs(lines) do
						if line == entry then
							return -- already present
						end
					end
					table.insert(lines, entry)
					vim.fn.writefile(lines, gitignore)
					vim.notify("Added 'scratch/' to .gitignore", vim.log.levels.INFO)
				end
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		-- {
		-- 	"<leader>ww",
		-- 	function()
		-- 		Snacks.bufdelete.delete()
		-- 	end,
		-- 	desc = "Delete current buffer",
		-- },
		{
			"<leader>wa",
			function()
				Snacks.bufdelete.other()
			end,
			desc = "Delete all buffers except current one",
		},
		{
			"<leader>gb",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse",
		},
		{
			"<leader>gB",
			function()
				Snacks.git.blame_line()
			end,
			desc = "Git Blame Line",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Snacks Next Reference",
			mode = { "n", "t" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Snacks Prev Reference",
			mode = { "n", "t" },
		},
	},
}
