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
			local host_alias = "qw-server"

			local function connect_qw(path)
				local target = host_alias
				if path and path ~= "" then
					target = ("%s:%s"):format(host_alias, path)
				end
				vim.cmd(("RemoteSSHFSConnect %s"):format(target))
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

			vim.keymap.set("n", "<leader>Rc", "<cmd>QWConnect<CR>", { desc = "[R]emote connect qw-server" })
			vim.keymap.set("n", "<leader>Ro", "<cmd>QWOpen<Space>", { desc = "[R]emote open path on qw-server" })
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
