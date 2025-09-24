local M = {}

local devicons = require("nvim-web-devicons")

devicons.setup({
	override_by_filename = {
		["application.properties"] = {
			icon = "", -- or use "", "󰟜", "⚙", "🔧"
			color = "#6DB33F",
			name = "Properties",
		},
	},
	override_by_extension = {
		["properties"] = {
			icon = "", -- or use "", "󰟜", "⚙", "🔧"
			color = "#6DB33F",
			name = "Properties",
		},
	},
})

M.my_current_buffer = function()
	local current_buf = vim.api.nvim_get_current_buf()

	-- Get current buffer info
	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(current_buf), ":t")
	local filetype = vim.bo[current_buf].filetype

	-- Hide buffer for unnamed buffers or specific filetypes
	local excluded_filetypes = {
		"NvimTree",
		"TelescopePrompt",
		"TelescopeResults",
		"help",
		-- "terminal",
		-- "toggleterm",
		"lazy",
		"mason",
		"lspinfo",
		"null-ls-info",
		"rest_nvim_result#Response",
		"qf", -- quickfix
		"", -- empty filetype
	}

	if filename == "" or vim.tbl_contains(excluded_filetypes, filetype) then
		return "" -- Return empty string for excluded buffers
	end

	-- Get icon and color with fallback for properties files
	local icon, icon_color = devicons.get_icon_color(filename)
	if not icon or not icon_color then
		if filetype and filetype ~= "" then
			icon, icon_color = devicons.get_icon_color_by_filetype(filetype)
		end
	end

	if filetype == "runner-terminal" then
		icon = "󰑮 " --  or 󰑮
		icon_color = "#00ff00"
	end

	-- Custom fallback for properties files
	if not icon and (filename:match("%.properties$") or filename == "application.properties") then
		icon = ""
		icon_color = "#6DB33F"
	end

	if not icon then
		icon = "󰈙"
	end
	if not icon_color then
		icon_color = "#B88339"
	end

	-- Set highlight groups for current buffer
	-- vim.api.nvim_set_hl(0, hl_group, { fg = "#000000", bg = icon_color })
	-- vim.api.nvim_set_hl(0, hl_group_bold, {
	-- 	fg = "#000000",
	-- 	bg = icon_color,
	-- 	bold = true,
	-- })

	-- Define highlights (transparent bg, fg = filetype color)
	local hl_group_icon = "LualineBufIcon"
	local hl_group_name = "LualineBufName"
	vim.api.nvim_set_hl(0, hl_group_icon, { fg = icon_color, bg = "NONE" })
	vim.api.nvim_set_hl(0, hl_group_name, { fg = icon_color, bg = "NONE", bold = true })

	-- Check if buffer is modified
	local modified = vim.bo[current_buf].modified and " ●" or ""

	-- Add filename truncation
	local max_filename_length = 37 -- Adjust this value as needed
	local truncated_filename = filename

	if string.len(filename) > max_filename_length then
		local start_chars = math.floor((max_filename_length - 3) / 2)
		local end_chars = max_filename_length - 3 - start_chars
		truncated_filename = string.sub(filename, 1, start_chars) .. "..." .. string.sub(filename, -end_chars)
	end

	-- Return formatted string
	-- return string.format("%%#%s# %s |%%*%%#%s# %s%s %%*", hl_group, icon, hl_group_bold, truncated_filename, modified)
	return string.format(
		"%%#%s#%s %%*%%#%s# %s%s %%*",
		hl_group_icon,
		icon,
		hl_group_name,
		truncated_filename,
		modified
	)
end

M.linter_info = function()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	if ft == "" or not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
		return ""
	end

	local lint = require("lint")
	local linters = lint.linters_by_ft[ft] or {}

	if #linters > 0 then
		return table.concat(linters, ",")
	end

	return ""
end

M.formatter_info = function()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	if ft == "" or not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
		return ""
	end

	local formatters = {}
	local ok, conform = pcall(require, "conform")
	if ok then
		local available = conform.list_formatters_for_buffer(buf)
		for _, name in ipairs(available) do
			table.insert(formatters, name)
		end
	end

	if #formatters > 0 then
		return table.concat(formatters, ",") -- 
	end

	return ""
end

M.is_wide_enough = function(min_width)
	min_width = min_width or 120 -- default minimum width
	return vim.fn.winwidth(0) > min_width
end

M.restore_session = function()
	local session_name = require("auto-session.lib").current_session_name(true)
	if session_name and session_name ~= "" and session_name ~= nil then
		local max_length = 17
		local is_wide = M.is_wide_enough(100)
		if #session_name > max_length and not is_wide then
			session_name = "..." .. string.sub(session_name, -(max_length - 3))
		end
		return " " .. session_name
	else
		return "  session"
	end
end

M.blank = function()
	return " "
end

return M
