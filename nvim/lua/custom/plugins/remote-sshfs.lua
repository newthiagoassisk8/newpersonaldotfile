return {
	{
		"nosduco/remote-sshfs.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		opts = function()
			local home = vim.fn.expand("$HOME")
			return {
				connections = {
					ssh_configs = {
						home .. "/.ssh/config",
					},
					ssh_known_hosts = home .. "/.ssh/known_hosts",
					sshfs_args = {
						"-o reconnect",
						"-o ConnectTimeout=5",
					},
				},
				mounts = {
					base_dir = home .. "/.sshfs",
					unmount_on_exit = true,
				},
				handlers = {
					on_connect = {
						change_dir = true,
					},
					on_disconnect = {
						clean_mount_folders = false,
					},
				},
				ui = {
					confirm = {
						connect = false,
						change_dir = false,
					},
				},
				log = {
					enabled = false,
					truncate = false,
					types = {
						all = false,
						util = false,
						handler = false,
						sshfs = false,
					},
				},
			}
		end,
		config = function(_, opts)
			require("remote-sshfs").setup(opts)
			pcall(require("telescope").load_extension, "remote-sshfs")

			local api = require("remote-sshfs.api")
			local connections = require("remote-sshfs.connections")
			local ssh_config_paths = opts.connections.ssh_configs or {}
			local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "remote-sshfs-host")
			local default_host_alias = "qw-server"
			local host_alias = default_host_alias

			local function has_sshfs()
				return vim.fn.executable("sshfs") == 1
			end

			local function notify_missing_sshfs()
				vim.notify(
					"[remote-sshfs] 'sshfs' nao encontrado no PATH. Instale o pacote 'sshfs' para usar este comando.",
					vim.log.levels.ERROR
				)
			end

			local function save_selected_host(alias)
				vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
				vim.fn.writefile({ alias }, state_file)
			end

			local function get_saved_host()
				if vim.fn.filereadable(state_file) == 0 then
					return nil
				end

				local lines = vim.fn.readfile(state_file)
				local alias = lines[1]
				if alias and alias ~= "" then
					return alias
				end
			end

			local function parse_ssh_hosts()
				local hosts = {}
				local seen = {}

				for _, config_path in ipairs(ssh_config_paths) do
					local expanded_path = vim.fn.expand(config_path)
					if vim.fn.filereadable(expanded_path) == 1 then
						for line in io.lines(expanded_path) do
							local host_names = line:match("^%s*Host%s+(.+)$")
							if host_names then
								for host_name in host_names:gmatch("%S+") do
									if not host_name:find("[%*%?]") and not seen[host_name] then
										seen[host_name] = true
										table.insert(hosts, host_name)
									end
								end
							end
						end
					end
				end

				table.sort(hosts)
				return hosts
			end

			local function load_host_overrides(alias)
				for _, config_path in ipairs(ssh_config_paths) do
					local expanded_path = vim.fn.expand(config_path)
					if vim.fn.filereadable(expanded_path) == 1 then
						local in_target_host = false
						local overrides = {}

						for line in io.lines(expanded_path) do
							local host_names = line:match("^%s*Host%s+(.+)$")
							if host_names then
								in_target_host = false
								for host_name in host_names:gmatch("%S+") do
									if host_name == alias then
										in_target_host = true
										break
									end
								end
							elseif in_target_host then
								local key, value = line:match("^%s*(%S+)%s+(.+)$")
								if key and value then
									overrides[key] = value
								end
							end
						end

						if not vim.tbl_isempty(overrides) then
							return overrides
						end
					end
				end

				return {}
			end

			local function set_current_host(alias, notify)
				host_alias = alias
				save_selected_host(alias)
				vim.g.remote_sshfs_current_host = alias

				if notify ~= false then
					vim.notify(("remote-sshfs host atual: %s"):format(alias), vim.log.levels.INFO)
				end
			end

			local function get_current_host()
				return host_alias
			end

			local function select_host(callback)
				local hosts = parse_ssh_hosts()
				if vim.tbl_isempty(hosts) then
					vim.notify("[remote-sshfs] nenhum host valido encontrado no ~/.ssh/config.", vim.log.levels.ERROR)
					return
				end

				vim.ui.select(hosts, {
					prompt = "Selecione o host SSH",
					format_item = function(item)
						if item == get_current_host() then
							return ("%s (atual)"):format(item)
						end

						return item
					end,
				}, function(choice)
					if not choice or choice == "" then
						return
					end

					set_current_host(choice)
					if callback then
						callback(choice)
					end
				end)
			end

			local function initialize_current_host()
				local available_hosts = parse_ssh_hosts()
				local saved_host = get_saved_host()

				if saved_host and vim.tbl_contains(available_hosts, saved_host) then
					set_current_host(saved_host, false)
					return
				end

				if vim.tbl_contains(available_hosts, default_host_alias) then
					set_current_host(default_host_alias, false)
					return
				end

				if available_hosts[1] then
					set_current_host(available_hosts[1], false)
				end
			end

			local function connect_current_host(path)
				if not has_sshfs() then
					notify_missing_sshfs()
					return
				end

				local current_host = get_current_host()
				local host = vim.deepcopy(connections.list_hosts()[host_alias] or {})
				if vim.tbl_isempty(host) then
					vim.notify(
						("[remote-sshfs] host '%s' nao encontrado no ~/.ssh/config."):format(current_host),
						vim.log.levels.ERROR
					)
					return
				end

				host = vim.tbl_extend("force", host, load_host_overrides(current_host))

				if path and path ~= "" then
					host.Path = path
				end

				connections.connect(host)
			end

			initialize_current_host()

			vim.api.nvim_create_user_command("QWConnect", function()
				connect_current_host()
			end, {
				desc = "Conecta ao host SSH atualmente selecionado",
			})

			vim.api.nvim_create_user_command("QWOpen", function(command_opts)
				connect_current_host(command_opts.args)
			end, {
				nargs = "?",
				complete = "dir",
				desc = "Conecta ao host selecionado e abre um diretorio remoto, ex.: :QWOpen /srv/app",
			})

			vim.api.nvim_create_user_command("QWDisconnect", function()
				api.disconnect()
			end, {
				desc = "Desmonta a conexao SSHFS atual",
			})

			vim.api.nvim_create_user_command("QWSelectHost", function()
				select_host()
			end, {
				desc = "Seleciona o host SSH atual a partir do ~/.ssh/config",
			})

			local function prompt_qw_open()
				vim.ui.input({
					prompt = ("Remote path for %s: "):format(get_current_host()),
					completion = "dir",
				}, function(input)
					if input == nil then
						return
					end

					vim.cmd.QWOpen(input)
				end)
			end

			vim.keymap.set("n", "<leader>Rc", "<cmd>QWConnect<CR>", { desc = "[R]emote connect current host" })
			vim.keymap.set("n", "<leader>Ro", prompt_qw_open, { desc = "[R]emote open path on current host" })
			vim.keymap.set("n", "<leader>Rf", api.find_files, { desc = "[R]emote find files" })
			vim.keymap.set("n", "<leader>Rg", api.live_grep, { desc = "[R]emote live grep" })
			vim.keymap.set("n", "<leader>Rd", api.disconnect, { desc = "[R]emote disconnect" })
			vim.keymap.set("n", "<leader>Rs", "<cmd>QWSelectHost<CR>", { desc = "[R]emote select current host" })
			vim.keymap.set("n", "<leader>Re", api.edit, { desc = "[R]emote edit ssh config" })

			require("remote-sshfs").callback.on_connect_success:add(function(host, mount_dir)
				vim.notify(("remote-sshfs conectado: %s -> %s"):format(host, mount_dir), vim.log.levels.INFO)
			end)
		end,
	},
}
