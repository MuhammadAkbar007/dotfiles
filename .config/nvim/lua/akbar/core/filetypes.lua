vim.filetype.add({
	pattern = {
		[".*/templates/.*%.html"] = "htmldjango",
		[".*%.html$"] = "htmldjango", -- if Django
		[".*%.jinja$"] = "htmldjango",
		[".*%.jinja2?$"] = "jinja",
	},
})
