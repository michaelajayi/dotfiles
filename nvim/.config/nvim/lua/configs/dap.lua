local dap = require("dap")
local dapui = require("dapui")

require("mason-nvim-dap").setup({
	ensure_installed = { "js-debug-adapter" },
	automatic_setup = false,
})

local js_debug_adapter = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter"

local function pick_free_port()
	local tcp = assert(vim.loop.new_tcp(), "Failed to create TCP handle")
	assert(tcp:bind("127.0.0.1", 0))
	local port = assert(tcp:getsockname().port, "Failed to get port")
	tcp:close()
	return port
end

dap.adapters["pwa-node"] = function(callback, _)
	local port = pick_free_port()
	callback({
		type = "server",
		host = "127.0.0.1",
		port = port,
		executable = {
			command = js_debug_adapter,
			args = { tostring(port), "127.0.0.1" },
		},
	})
end

vim.schedule(function()
	if vim.fn.executable(js_debug_adapter) ~= 1 then
		pcall(
			vim.notify,
			"js-debug-adapter not found. Install via :Mason (js-debug-adapter).",
			vim.log.levels.ERROR
		)
	end
	if vim.fn.exepath("node") == "" then
		pcall(vim.notify, "Node.js not found in PATH. DAP may not work.", vim.log.levels.WARN)
	end
end)

dapui.setup()

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>dc", function()
	dap.continue()
end, { desc = "DAP continue" })
map("n", "<leader>do", function()
	dap.step_over()
end, { desc = "DAP step over" })
map("n", "<leader>di", function()
	dap.step_into()
end, { desc = "DAP step into" })
map("n", "<leader>dO", function()
	dap.step_out()
end, { desc = "DAP step out" })
map("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { desc = "DAP toggle breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP conditional breakpoint" })
map("n", "<leader>dr", function()
	dap.repl.open()
end, { desc = "DAP REPL" })
map("n", "<leader>dl", function()
	dap.run_last()
end, { desc = "DAP run last" })
map("n", "<leader>du", function()
	dapui.toggle()
end, { desc = "DAP UI toggle" })
map("n", "<leader>dn", function()
	local script = vim.fn.input("npm script: ")
	if script == nil or script == "" then
		return
	end
	dap.run({
		type = "pwa-node",
		request = "launch",
		name = "Launch npm script",
		cwd = "${workspaceFolder}",
		runtimeExecutable = "npm",
		runtimeArgs = { "run", script },
		sourceMaps = true,
		console = "integratedTerminal",
	})
end, { desc = "DAP launch npm script" })

-- Auto-open/close dap-ui for active sessions
local dapui_group = "dapui_config"
dap.listeners.after.event_initialized[dapui_group] = function()
	dapui.open()
end

dap.listeners.before.event_terminated[dapui_group] = function()
	dapui.close()
end

dap.listeners.before.event_exited[dapui_group] = function()
	dapui.close()
end

local skip_files = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" }
local resolve_sourcemap_locations = { "${workspaceFolder}/**", "!**/node_modules/**" }

local function path_exists(path)
	return vim.loop.fs_stat(path) ~= nil
end

local function find_root()
	local marker = vim.fs.find({ "package.json", "tsconfig.json", ".git" }, { upward = true })[1]
	return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

local function read_json(path)
	local ok, content = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end
	local ok_decode, json = pcall(vim.fn.json_decode, table.concat(content, "\n"))
	if not ok_decode then
		return nil
	end
	return json
end

local function read_package_json(root)
	local path = root .. "/package.json"
	if not path_exists(path) then
		return nil
	end
	return read_json(path)
end

local function detect_script(pkg)
	if not pkg or type(pkg.scripts) ~= "table" then
		return nil
	end
	for _, name in ipairs({ "dev", "start", "debug", "serve" }) do
		if pkg.scripts[name] then
			return name
		end
	end
	for name, cmd in pairs(pkg.scripts) do
		if type(cmd) == "string" then
			if cmd:match("nodemon") or cmd:match("tsx") or cmd:match("ts%-node") or cmd:match("node") then
				return name
			end
		end
	end
	return nil
end

local function detect_entry(root, pkg)
	if pkg and type(pkg.main) == "string" then
		local candidate = root .. "/" .. pkg.main
		if path_exists(candidate) then
			return candidate
		end
	end
	local candidates = {
		"src/index.ts",
		"src/server.ts",
		"src/app.ts",
		"index.ts",
		"server.ts",
		"app.ts",
		"src/index.js",
		"src/server.js",
		"src/app.js",
		"index.js",
		"server.js",
		"app.js",
		"src/index.mjs",
		"src/server.mjs",
		"index.mjs",
		"server.mjs",
		"src/index.cjs",
		"src/server.cjs",
		"index.cjs",
		"server.cjs",
		"dist/index.js",
		"dist/server.js",
	}
	for _, rel in ipairs(candidates) do
		local path = root .. "/" .. rel
		if path_exists(path) then
			return path
		end
	end
	return vim.fn.expand("%:p")
end

local function detect_package_manager(root)
	if path_exists(root .. "/pnpm-lock.yaml") then
		return "pnpm"
	end
	if path_exists(root .. "/yarn.lock") then
		return "yarn"
	end
	if path_exists(root .. "/bun.lockb") or path_exists(root .. "/bun.lock") then
		return "bun"
	end
	return "npm"
end

local function is_typescript(path)
	return path:match("%.ts$") or path:match("%.tsx$")
end

local function detect_ts_runtime(root, pkg)
	local tsx_bin = root .. "/node_modules/.bin/tsx"
	if path_exists(tsx_bin) then
		return {
			label = "tsx",
			exec = "node",
			args = { "--enable-source-maps", "--loader", "tsx" },
		}
	end
	local ts_node_bin = root .. "/node_modules/.bin/ts-node"
	if path_exists(ts_node_bin) then
		local is_esm = pkg and pkg.type == "module"
		if is_esm then
			return {
				label = "ts-node (esm)",
				exec = "node",
				args = { "--enable-source-maps", "--loader", "ts-node/esm" },
			}
		end
		return {
			label = "ts-node",
			exec = "node",
			args = { "--enable-source-maps", "-r", "ts-node/register" },
		}
	end
	return nil
end

local function detect_dist_entry(root, entry)
	local base = vim.fn.fnamemodify(entry, ":t")
	local dist_candidates = {
		root .. "/dist/" .. base:gsub("%.ts$", ".js"):gsub("%.tsx$", ".js"),
		root .. "/build/" .. base:gsub("%.ts$", ".js"):gsub("%.tsx$", ".js"),
		root .. "/lib/" .. base:gsub("%.ts$", ".js"):gsub("%.tsx$", ".js"),
		root .. "/dist/index.js",
		root .. "/dist/server.js",
	}
	for _, path in ipairs(dist_candidates) do
		if path_exists(path) then
			return path
		end
	end
	return nil
end

local function auto_express_config()
	local root = find_root()
	local pkg = read_package_json(root)
	local script = detect_script(pkg)
	local config = {
		type = "pwa-node",
		request = "launch",
		cwd = root,
		console = "integratedTerminal",
		sourceMaps = true,
		protocol = "inspector",
		autoAttachChildProcesses = true,
		skipFiles = skip_files,
		resolveSourceMapLocations = resolve_sourcemap_locations,
	}

	if script then
		local pm = detect_package_manager(root)
		config.name = "Auto: " .. pm .. " run " .. script
		config.runtimeExecutable = pm
		config.runtimeArgs = { "run", script }
		return config
	end

	local entry = detect_entry(root, pkg)
	config.program = entry

	if is_typescript(entry) then
		local runtime = detect_ts_runtime(root, pkg)
		if runtime then
			config.name = "Auto: " .. runtime.label .. " (" .. vim.fn.fnamemodify(entry, ":t") .. ")"
			config.runtimeExecutable = runtime.exec
			config.runtimeArgs = runtime.args
			return config
		end

		local dist_entry = detect_dist_entry(root, entry)
		if dist_entry then
			config.name = "Auto: dist (" .. vim.fn.fnamemodify(dist_entry, ":t") .. ")"
			config.program = dist_entry
			config.runtimeExecutable = "node"
			config.runtimeArgs = { "--enable-source-maps" }
			return config
		end

		vim.schedule(function()
			vim.notify(
				"TS entry detected but no tsx/ts-node and no dist output. Install tsx or ts-node, or build to dist/.",
				vim.log.levels.WARN
			)
		end)
	end

	config.name = "Auto: node (" .. vim.fn.fnamemodify(entry, ":t") .. ")"
	config.runtimeExecutable = "node"
	config.runtimeArgs = { "--enable-source-maps" }
	return config
end

local function auto_value(field)
	return function()
		local cfg = auto_express_config()
		return cfg[field]
	end
end

local function add_config(language, config)
	dap.configurations[language] = dap.configurations[language] or {}
	table.insert(dap.configurations[language], config)
end

local auto_launch = {
	name = auto_value("name"),
	type = "pwa-node",
	request = "launch",
	cwd = auto_value("cwd"),
	program = auto_value("program"),
	runtimeExecutable = auto_value("runtimeExecutable"),
	runtimeArgs = auto_value("runtimeArgs"),
	sourceMaps = true,
	protocol = "inspector",
	console = "integratedTerminal",
	autoAttachChildProcesses = true,
	skipFiles = skip_files,
	resolveSourceMapLocations = resolve_sourcemap_locations,
}

for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
	add_config(language, auto_launch)

	add_config(language, {
		type = "pwa-node",
		request = "attach",
		name = "Attach to process",
		processId = require("dap.utils").pick_process,
		cwd = "${workspaceFolder}",
		skipFiles = skip_files,
		resolveSourceMapLocations = resolve_sourcemap_locations,
	})

	add_config(language, {
		type = "pwa-node",
		request = "attach",
		name = "Attach :9229",
		port = 9229,
		address = "127.0.0.1",
		cwd = "${workspaceFolder}",
		skipFiles = skip_files,
		resolveSourceMapLocations = resolve_sourcemap_locations,
	})
end
