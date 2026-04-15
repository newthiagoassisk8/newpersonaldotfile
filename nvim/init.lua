vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

require("config.core")

if vim.g.vscode then
	require("config.vscode")
else
	require("config.native")
end
