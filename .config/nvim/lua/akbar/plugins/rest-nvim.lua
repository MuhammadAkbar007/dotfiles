return {
	-- https://github.com/rest-nvim/rest.nvim
	-- :TSInstall http
	"rest-nvim/rest.nvim",
	event = "VeryLazy",
	config = function()
		-- Function to save response and add to .gitignore if not added
		local function save_response_to_file(content)
			local filename = vim.fn.getcwd() .. "/rest_nvim_result#Response"

			-- Add to .gitignore if it doesn't already exist
			local gitignore_path = vim.fn.getcwd() .. "/.gitignore"
			local gitignore_content = ""
			local file_ignored = false

			-- Read existing .gitignore if it exists
			local gitignore_file = io.open(gitignore_path, "r")
			if gitignore_file then
				gitignore_content = gitignore_file:read("*all")
				gitignore_file:close()

				-- Check if our response file is already ignored
				if gitignore_content:match("rest_nvim_result#Response") then
					file_ignored = true
				end
			end

			-- Add to .gitignore if needed
			if not file_ignored then
				gitignore_file = io.open(gitignore_path, "a+")
				if gitignore_file then
					-- Add a newline if the file doesn't end with one
					if gitignore_content ~= "" and not gitignore_content:match("\n$") then
						gitignore_file:write("\n")
					end

					-- Ignore the rest_response file
					gitignore_file:write("rest_nvim_result#Response\n")
					gitignore_file:close()
				end
			end

			-- Write content to file with modeline
			local file = io.open(filename, "w")
			if file then
				file:write(content)
				file:close()
				vim.notify("Response saved to " .. filename, vim.log.levels.INFO)
				return filename
			else
				vim.notify("Failed to save response", vim.log.levels.ERROR)
				return nil
			end
		end

		vim.g.rest_nvim = {
			result = {
				show_url = true,
				show_http_info = true,
				show_headers = true,
				formatters = {
					json = "jq",
					html = function(body)
						return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
					end,
				},
			},
			highlight = {
				enabled = true,
				timeout = 150,
			},
		}

		-- Set up autocmd to move the split to the bottom
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "httpResult", -- This is the filetype for rest.nvim result
			callback = function()
				vim.cmd("belowright split") -- Moves the split to the bottom (horizontal split)
			end,
		})

		-- Function to manually save the current buffer if needed
		local function save_current_buffer_response()
			local buf = vim.api.nvim_get_current_buf()

			-- Try multiple ways to detect if this is a response buffer
			local is_response_buffer = false
			local filetype = vim.bo[buf].filetype
			local bufname = vim.api.nvim_buf_get_name(buf)

			if filetype == "httpResult" then
				is_response_buffer = true
			elseif bufname:match("rest_nvim_result") or bufname:match("rest%.nvim") then
				is_response_buffer = true
			end

			if not is_response_buffer then
				vim.notify("Not in a REST response buffer", vim.log.levels.WARN)
				return
			end

			-- Get all lines from the current buffer
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local content = table.concat(lines, "\n")

			-- Save the response
			save_response_to_file(content)
		end

		-- Regular keymap for running REST requests
		vim.keymap.set("n", "<leader>rr", ":Rest run<CR>", { noremap = true, silent = true })

		-- Manual keymap for saving the response buffer
		vim.keymap.set("n", "<leader>rs", save_current_buffer_response, {
			noremap = true,
			silent = true,
			desc = "Save REST response buffer to file",
		})
	end,
}
