local M = {}

function M:setup()
	local jdtls = require("jdtls")
	local home = vim.loop.os_homedir()
	local mason_path = vim.fn.stdpath("data") .. "/mason"

	local java_debug_path = mason_path .. "/packages/java-debug-adapter"
	local java_test_path = mason_path .. "/packages/java-test"

	local bundles = {}

	vim.list_extend(
		bundles,
		vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
	)

	vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n"))

	local lombok_path = mason_path .. "/share/jdtls/lombok.jar"
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_dir = home .. "/.cache/jdtls-workspace/" .. project_name

	local config = {
		cmd = {
			-- "jdtls",
			vim.fn.expand(mason_path .. "/bin/jdtls"),
			"-data",
			workspace_dir,
			"--jvm-arg=-javaagent:" .. lombok_path,
			-- "--jvm-arg=" .. string.format("-javaagent:%s", vim.fn.expand("$MASON/share/jdtls/lombok.jar")),
			"--jvm-arg=-Xmx4G",
			"--jvm-arg=--add-modules=ALL-SYSTEM",
			"--jvm-arg=--add-opens=java.base/java.util=ALL-UNNAMED",
			"--jvm-arg=--add-opens=java.base/java.lang=ALL-UNNAMED",
			"--java-options=-XX:+UseG1GC",
			"--java-options=-XX:+UseStringDeduplication",
			"--log=debug",
		},
		root_dir = require("jdtls.setup").find_root({ "gradlew", ".git", "mvnw", "pom.xml", "build.gradle" }),
		settings = {
			java = {
				compiler = { encoding = "UTF-8" },
				eclipse = {
					downloadSources = true,
				},
				maven = {
					downloadSources = true,
				},
				implementationsCodeLens = {
					enabled = true,
				},
				referencesCodeLens = {
					enabled = true,
				},
				references = {
					includeDecompiledSources = true,
				},
				format = {
					enabled = true,
					settings = { encoding = "UTF-8" },
					-- Formatting works by default, but you can refer to a specific file/URL if you choose
					-- settings = {
					-- 	encoding = "UTF-8",
					-- 	url = "https://github.com/google/styleguide/blob/gh-pages/intellij-java-google-style.xml",
					-- 	profile = "GoogleStyle",
					-- },
				},
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" },
				completion = {
					postfix = { enabled = true },
					favoriteStaticMembers = {
						"org.hamcrest.MatcherAssert.assertThat",
						"org.hamcrest.Matchers.*",
						"org.hamcrest.CoreMatchers.*",
						"org.junit.Assert.*",
						"org.junit.Assume.*",
						"org.junit.jupiter.api.Assertions.*",
						"org.junit.jupiter.api.Assumptions.*",
						"org.junit.jupiter.api.DynamicContainer.*",
						"org.junit.jupiter.api.DynamicTest.*",
						"java.util.Objects.requireNonNull",
						"java.util.Objects.requireNonNullElse",
						"org.mockito.Mockito.*",
						"org.assertj.core.api.Assertions.*",
					},
					importOrder = {
						"java",
						"javax",
						"com",
						"org",
					},
				},
				sources = {
					organizeImports = {
						starThreshold = 9999,
						staticStarThreshold = 9999,
					},
				},
				codeGeneration = {
					toString = {
						template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
					},
					useBlocks = true,
				},
				inlayHints = {
					parameterNames = { enabled = "all" },
				},
				spring = {
					boot = {
						enabled = true,
					},
				},
				configuration = {
					updateBuildConfiguration = "automatic",
					runtimes = {
						{
							name = "JavaSE-1.8",
							path = "/usr/lib/jvm/java-8-openjdk-amd64",
						},
						-- {
						-- 	name = "JavaSE-17",
						-- 	path = "/usr/lib/jvm/java-17-openjdk-amd64",
						-- },
						-- {
						-- 	name = "JavaSE-23",
						-- 	path = "/usr/lib/jvm/jdk-23.0.1-oracle-x64",
						-- },
						-- {
						-- 	name = "JavaOpenJdk-21",
						-- 	path = "/usr/lib/jvm/java-21-openjdk-amd64/",
						-- },
						{
							name = "JavaSE-25",
							path = "/usr/lib/jvm/jdk-25.0.1-oracle-x64",
						},
					},
				},
			},
		},
		init_options = {
			bundles = bundles,
			extendedClientCapabilities = jdtls.extendedClientCapabilities,
		},
		capabilities = require("cmp_nvim_lsp").default_capabilities(),

		flags = {
			allow_incremental_sync = true,
		},

		on_attach = function(client, bufnr)
			local keymap = vim.keymap
			local opts = { buffer = bufnr, silent = true }

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "See available code actions (Alt + Enter)"
			keymap.set({ "n", "v" }, "<A-CR>", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, opts)

			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			-- JDTLS specific commands
			opts.desc = "Organize imports"
			keymap.set("n", "<leader>joi", jdtls.organize_imports, opts)

			opts.desc = "Extract variable"
			keymap.set("v", "<leader>jev", jdtls.extract_variable, opts)

			opts.desc = "Extract constant"
			keymap.set("v", "<leader>jec", jdtls.extract_constant, opts)

			opts.desc = "Extract method"
			keymap.set("v", "<leader>jem", jdtls.extract_method, opts)

			jdtls.setup_dap({ hotcodereplace = "auto", config_overrides = {} })
			require("jdtls.dap").setup_dap_main_class_configs()

			opts.desc = "Debug Java test method under cursor"
			keymap.set("n", "<leader>jtm", jdtls.test_nearest_method, opts)

			opts.desc = "Debug Java test class"
			keymap.set("n", "<leader>jtc", jdtls.test_class, opts)

			-- Attach navbuddy
			if pcall(require, "nvim-navbuddy") then
				require("nvim-navbuddy").attach(client, bufnr)
			end
		end,
	}

	require("jdtls").start_or_attach(config)
end

return M
