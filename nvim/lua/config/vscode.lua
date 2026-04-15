require("config.lazy").setup("plugins.vscode")

local ok, vscode = pcall(require, "vscode")
if not ok then
	return
end

local function map(keys, action, desc, opts)
	vim.keymap.set("n", keys, function()
		vscode.action(action, opts)
	end, { silent = true, desc = desc })
end

map("gd", "editor.action.revealDefinition", "Go to definition")
map("gr", "editor.action.referenceSearch.trigger", "Show references")
map("gi", "editor.action.goToImplementation", "Go to implementation")
map("gI", "editor.action.goToImplementation", "Go to implementation")
map("gD", "editor.action.revealDeclaration", "Go to declaration")
map("gy", "editor.action.goToTypeDefinition", "Go to type definition")
map("K", "editor.action.showHover", "Hover")
map("<leader>rn", "editor.action.rename", "Rename symbol")
map("<leader>ca", "editor.action.quickFix", "Code action", { range = false })
map("<leader>dd", "workbench.actions.view.problems", "Diagnostics")
map("<leader>ds", "workbench.action.gotoSymbol", "Document symbols")
map("<leader>ws", "workbench.action.showAllSymbols", "Workspace symbols")
map("<leader>f", "editor.action.formatDocument", "Format document")
