return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern(
			"compile_commands.json",
			"compile_flags.txt"
			-- ".git"
		)(fname) or vim.fn.getcwd()
	end,
}
