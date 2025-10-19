return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"mfussenegger/nvim-jdtls",
		"nvim-neotest/nvim-nio",
		"folke/lazydev.nvim",
		"theHamsta/nvim-dap-virtual-text",
	},

	opts = {
		expand_lines = true,
		floating = {
			border = "single",
			mappings = {
				close = { "q", "<Esc>" },
			},
		},
		force_buffers = true,
	},

	config = function(_, opts)
		local dap = require("dap")
		local dapui = require("dapui")

		require("lazydev").setup({
			library = { "nvim-dap-ui" },
		})

		require("nvim-dap-virtual-text").setup({})

		dapui.setup(opts)

		local function run_maven_project()
			local bufnr = vim.api.nvim_get_current_buf()
			local filename = vim.api.nvim_buf_get_name(bufnr)
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

			-- Check for main method
			local in_main_class = false
			for _, line in ipairs(lines) do
				if line:match("public%s+static%s+void%s+main") then
					in_main_class = true
					break
				end
			end

			if not in_main_class then
				vim.notify("No main method found in this file", vim.log.levels.WARN)
				return
			end

			-- Extract class name
			local class_name = vim.fn.fnamemodify(filename, ":t:r")

			-- Extract package name
			local package_name = ""
			for _, line in ipairs(lines) do
				local match = line:match("package%s+([%w%.]+)")
				if match then
					package_name = match
					break
				end
			end

			-- Compose full class name
			local full_class_name = (package_name ~= "" and package_name .. "." or "") .. class_name

			vim.ui.input({ prompt = "Main class: ", default = full_class_name }, function(input)
				if input and input ~= "" then
					local main_class = input
					local cmd = "mvn clean compile exec:java -Dexec.mainClass=" .. main_class

					-- Get project name
					local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

					vim.cmd("botright split | resize 15 | terminal " .. cmd)
					vim.cmd("normal G")

					local term_buf = vim.api.nvim_get_current_buf()
					local custom_name = "r_" .. project_name .. "_" .. class_name .. "_r"

					vim.api.nvim_buf_set_name(term_buf, custom_name)
					vim.bo[term_buf].filetype = "runner-terminal"
					vim.bo[term_buf].bufhidden = "hide"

					vim.notify("Running: " .. cmd, vim.log.levels.INFO)
				else
					print("No main class provided. Aborted.")
				end
			end)
		end

		local function run_spring_boot_project()
			if vim.g.spring_boot_job_id then
				vim.notify("Spring Boot project is already running", vim.log.levels.WARN)
				return
			end

			-- Check if it's a valid Spring Boot project
			local function is_spring_boot_project()
				return vim.fn.filereadable("pom.xml") == 1 or vim.fn.filereadable("build.gradle") == 1
			end

			if not is_spring_boot_project() then
				vim.notify("Not a Spring Boot project", vim.log.levels.WARN)
				return
			end

			-- Try to extract the @SpringBootApplication class name
			local main_class_name = "springboot_app"
			for _, file in ipairs(vim.fn.glob("**/*.java", true, true)) do
				local lines = vim.fn.readfile(file)
				for _, line in ipairs(lines) do
					if line:match("@SpringBootApplication") then
						main_class_name = vim.fn.fnamemodify(file, ":t:r")
						break
					end
				end
			end

			-- Use project folder name as project name
			local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

			-- Compose command
			local cmd = "mvn spring-boot:run"
			vim.notify("Running Spring Boot project: " .. cmd, vim.log.levels.INFO)

			-- Open terminal in bottom split and run the command
			vim.cmd("botright split | resize 15 | terminal " .. cmd)
			vim.cmd("normal G")

			-- Get buffer and set custom name + filetype
			local current_buffer = vim.api.nvim_get_current_buf()
			local custom_name = "r_" .. project_name .. "_" .. main_class_name .. "_r"

			vim.api.nvim_buf_set_name(current_buffer, custom_name)
			vim.bo[current_buffer].filetype = "runner-terminal"
			vim.bo[current_buffer].bufhidden = "hide"

			-- Save job ID for stopping later
			vim.g.spring_boot_job_id = vim.b.terminal_job_id
		end

		local function stop_spring_boot_project()
			if not vim.g.spring_boot_job_id then
				vim.notify("No Spring Boot project is currently running", vim.log.levels.WARN)
				return
			end

			vim.fn.jobstop(vim.g.spring_boot_job_id)

			vim.g.spring_boot_job_id = nil

			vim.notify("Spring Boot project stopped", vim.log.levels.INFO)
		end

		------------------------------------------------------
		-- Maven Compile & Log Management for Neovim
		------------------------------------------------------

		-- Helper to write timestamp header
		local function write_compile_header(log_file)
			local header = string.format("\n\n----- [COMPILE STARTED AT %s] -----\n", os.date("%Y-%m-%d %H:%M:%S"))
			local f = io.open(log_file, "a")
			if f then
				f:write(header)
				f:close()
			end
		end

		-- Compile the Maven project intelligently
		local function compile_maven_project()
			local project_root = vim.fn.getcwd()
			local cmd = { "mvn", "-f", project_root .. "/pom.xml", "compile" }
			local log_file = project_root .. "/.nvim_maven_compile.log"

			-- Stop previous compile job if running
			if vim.g.maven_compile_job_id then
				vim.fn.jobstop(vim.g.maven_compile_job_id)
				vim.notify("🛑 Previous compile job stopped.", vim.log.levels.WARN)
				vim.g.maven_compile_job_id = nil
			end

			-- Add a timestamped header to log file
			write_compile_header(log_file)

			-- Notify user
			vim.notify("🔨 Compiling project in " .. project_root, vim.log.levels.INFO)

			-- If Spring Boot is running, compile silently (no terminal)
			if vim.g.spring_boot_job_id then
				vim.g.maven_compile_job_id = vim.fn.jobstart(cmd, {
					cwd = project_root,
					stdout_buffered = true,
					stderr_buffered = true,
					on_stdout = function(_, data)
						if data then
							local f = io.open(log_file, "a")
							if f then
								f:write(table.concat(data, "\n") .. "\n")
								f:close()
							end
						end
					end,
					on_stderr = function(_, data)
						if data then
							local f = io.open(log_file, "a")
							if f then
								f:write(table.concat(data, "\n") .. "\n")
								f:close()
							end
						end
					end,
					on_exit = function(_, code)
						vim.g.maven_compile_job_id = nil
						local msg = code == 0 and "✅ Compile successful." or "❌ Compile failed. Check logs."
						local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
						vim.notify(msg, level)
					end,
				})
			else
				-- If Spring Boot not running — show terminal with logs
				vim.cmd(
					"botright split | resize 10 | terminal mvn -f "
						.. project_root
						.. "/pom.xml compile | tee -a "
						.. log_file
				)
				vim.cmd("normal G")

				local term_buf = vim.api.nvim_get_current_buf()
				local project_name = vim.fn.fnamemodify(project_root, ":t")
				local custom_name = "compile_" .. project_name .. "_terminal"

				vim.api.nvim_buf_set_name(term_buf, custom_name)
				vim.bo[term_buf].filetype = "runner-terminal"
				vim.bo[term_buf].bufhidden = "hide"
			end
		end

		-- View last compile logs in a scratch buffer
		local function open_compile_logs()
			local project_root = vim.fn.getcwd()
			local log_file = project_root .. "/.nvim_maven_compile.log"

			if vim.fn.filereadable(log_file) == 0 then
				vim.notify("No compile log found for this project.", vim.log.levels.WARN)
				return
			end

			vim.cmd("vsplit " .. log_file)
			vim.bo.readonly = true
			vim.bo.modifiable = false
			vim.bo.filetype = "log"
			vim.cmd("normal! G")
		end

		vim.keymap.set("n", "<leader>mc", compile_maven_project, { desc = "Maven compile project (auto & log)" })
		vim.keymap.set("n", "<leader>ml", open_compile_logs, { desc = "Open Maven compile logs" })

		vim.api.nvim_set_hl(0, "DapStoppedHl", { fg = "#98BB6C", bg = "#2A2A2A", bold = true })
		vim.api.nvim_set_hl(0, "DapStoppedLineHl", { bg = "#204028", bold = true })
		vim.fn.sign_define(
			"DapStopped",
			{ text = " ", texthl = "DapStoppedHl", linehl = "DapStoppedLineHl", numhl = "" }
		)
		vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = " ", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = " ", texthl = "DiagnosticSignError", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = " ", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Debug (Attach) - Remote",
				hostName = "127.0.0.1",
				port = 5005,
			},
			{
				type = "java",
				request = "launch",
				name = "Debug (Launch) - Current File",
				mainClass = "${file}",
				projectName = "${workspaceFolder}",
			},
			{
				name = "Debug Maven Application",
				type = "java",
				request = "launch",
				mainClass = function()
					return vim.fn.input(
						"Main class: ",
						"",
						'customlist,v:lua.require("jdtls").get_main_class_candidates'
					)
				end,
				projectName = "${workspaceFolder}",
				classPaths = function()
					local result = {}
					local output = vim.fn.system("mvn dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt")
					if vim.v.shell_error ~= 0 then
						print("Failed to get classpath: " .. output)
						return result
					end
					local file = io.open("/tmp/cp.txt", "r")
					if file then
						local classpath = file:read("*all")
						file:close()
						for path in string.gmatch(classpath, "[^:]+") do
							table.insert(result, path)
						end
					end
					table.insert(result, vim.fn.getcwd() .. "/target/classes")
					return result
				end,
				vmArgs = "-Xmx2g",
			},
		}

		vim.keymap.set("n", "<leader>sr", run_spring_boot_project, { desc = "Run Spring Boot local project" })
		vim.keymap.set("n", "<leader>sx", stop_spring_boot_project, { desc = "Stop Spring Boot local project" })
		vim.keymap.set("n", "<Leader>mr", run_maven_project, { desc = "Run Maven local project" })

		vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Toggle breakpoint of nvim-dap" })
		vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Start or continue nvim-dap" })
		vim.keymap.set("n", "<Leader>di", dap.step_into, { desc = "Step into" })
		vim.keymap.set("n", "<Leader>do", dap.step_over, { desc = "Step over" })
		vim.keymap.set("n", "<Leader>dO", dap.step_out, { desc = "Step out" })
		vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Open REPL" })
		vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "Run last debug configuration" })
		vim.keymap.set("n", "<Leader>dx", dap.terminate, { desc = "Terminate debug session" })
	end,
}
