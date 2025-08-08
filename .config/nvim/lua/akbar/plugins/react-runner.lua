return {
	dir = vim.fn.stdpath("config") .. "/lua/akbar/plugins",
	name = "my-bufferline",
	config = function()
		local devicons = require("nvim-web-devicons")

		local function render_bufferline()
			local buffers = vim.api.nvim_list_bufs()
			local current_buf = vim.api.nvim_get_current_buf()
			local result = {}

			for _, bufnr in ipairs(buffers) do
				if vim.bo[bufnr].buflisted then
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
					if filename == "" then
						filename = "[No Name]"
					end

					local icon, icon_color = devicons.get_icon_color(filename)
					icon = icon or " "
					icon_color = icon_color or "#B88339"

					local is_current = bufnr == current_buf
					local modified = vim.bo[bufnr].modified and " ●" or ""

					table.insert(
						result,
						string.format(
							"%%#%s# %s %s%s %%*",
							is_current and "BufferLineActive" or "BufferLineInactive",
							icon,
							filename,
							modified
						)
					)
				end
			end

			vim.api.nvim_echo({ { table.concat(result, " "), "Normal" } }, false, {})
		end

		local function setup_highlights()
			vim.api.nvim_set_hl(0, "BufferLineActive", { fg = "#000000", bg = "#B88339", bold = true })
			vim.api.nvim_set_hl(0, "BufferLineInactive", { fg = "#B88339", bg = "#303030" })
		end

		vim.keymap.set("n", "<leader>rbl", render_bufferline, {
			desc = "Show custom bufferline in command area",
		})

		setup_highlights()
	end,
}
