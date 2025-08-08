local function run_python_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(bufnr)

	-- Check if current file is a Python file
	if not filename:match("%.py$") then
		vim.notify("Current file is not a Python file", vim.log.levels.WARN)
		return
	end

	-- Get just the filename without path
	local file = vim.fn.expand("%:t")
	local cmd = "python3 " .. file
	local terminal_name = "r_" .. file .. "_r"

	-- Check if terminal buffer with this name already exists
	local existing_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if buf_name:match(terminal_name .. "$") then
				existing_buf = buf
				break
			end
		end
	end

	-- If existing terminal buffer found, close it
	if existing_buf then
		-- Find and close any windows showing this buffer
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == existing_buf then
				vim.api.nvim_win_close(win, false)
			end
		end
		-- Delete the buffer
		vim.api.nvim_buf_delete(existing_buf, { force = true })
	end

	-- Store the original window to return to it
	-- local original_win = vim.api.nvim_get_current_win()

	-- Open terminal in bottom split and run the command
	vim.cmd("botright split | resize 15 | terminal " .. cmd)
	vim.cmd("normal G")

	local term_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(term_buf, terminal_name)
	vim.bo[term_buf].bufhidden = "hide"
	vim.bo[term_buf].filetype = "runner-terminal"

	-- Return focus to the original window
	-- vim.api.nvim_set_current_win(original_win)

	vim.notify("Run: " .. cmd, vim.log.levels.INFO)
end

-- Add this keymap alongside your existing ones
vim.keymap.set("n", "<leader>pr", run_python_file, { desc = "Run Python file" })
