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
			local host_alias = "qw-server"
			local ssh_config_paths = opts.connections.ssh_configs or {}
			local function has_sshfs()
				return vim.fn.executable("sshfs") == 1
			end

			local function notify_missing_sshfs()
				vim.notify(
					"[remote-sshfs] 'sshfs' nao encontrado no PATH. Instale o pacote 'sshfs' para usar este comando.",
					vim.log.levels.ERROR
				)
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

			local function connect_qw(path)
				if not has_sshfs() then
					notify_missing_sshfs()
					return
				end

				local host = vim.deepcopy(connections.list_hosts()[host_alias] or {})
				if vim.tbl_isempty(host) then
					vim.notify(
						("[remote-sshfs] host '%s' nao encontrado no ~/.ssh/config."):format(host_alias),
						vim.log.levels.ERROR
					)
					return
				end

				host = vim.tbl_extend("force", host, load_host_overrides(host_alias))

				if path and path ~= "" then
					host.Path = path
				end

				connections.connect(host)
			end

			vim.api.nvim_create_user_command("QWConnect", function()
				connect_qw()
			end, {
				desc = "Conecta ao host SSH qw-server usando o alias do ~/.ssh/config",
			})

			vim.api.nvim_create_user_command("QWOpen", function(command_opts)
				connect_qw(command_opts.args)
			end, {
				nargs = "?",
				complete = "dir",
				desc = "Conecta ao qw-server e abre um diretorio remoto, ex.: :QWOpen /srv/app",
			})

			vim.api.nvim_create_user_command("QWDisconnect", function()
				api.disconnect()
			end, {
				desc = "Desmonta a conexao SSHFS atual",
			})

			local function prompt_qw_open()
				vim.ui.input({
					prompt = "Remote path for qw-server: ",
					completion = "dir",
				}, function(input)
					if input == nil then
						return
					end

					vim.cmd.QWOpen(input)
				end)
			end

			vim.keymap.set("n", "<leader>Rc", "<cmd>QWConnect<CR>", { desc = "[R]emote connect qw-server" })
			vim.keymap.set("n", "<leader>Ro", prompt_qw_open, { desc = "[R]emote open path on qw-server" })
			vim.keymap.set("n", "<leader>Rf", api.find_files, { desc = "[R]emote find files" })
			vim.keymap.set("n", "<leader>Rg", api.live_grep, { desc = "[R]emote live grep" })
			vim.keymap.set("n", "<leader>Rd", api.disconnect, { desc = "[R]emote disconnect" })
			vim.keymap.set("n", "<leader>Rs", api.connect, { desc = "[R]emote select host" })
			vim.keymap.set("n", "<leader>Re", api.edit, { desc = "[R]emote edit ssh config" })

			require("remote-sshfs").callback.on_connect_success:add(function(host, mount_dir)
				vim.notify(("remote-sshfs conectado: %s -> %s"):format(host, mount_dir), vim.log.levels.INFO)
			end)
		end,
	},
}
