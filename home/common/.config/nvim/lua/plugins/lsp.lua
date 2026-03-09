return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lspconfig = require("lspconfig")
			local configs = require("lspconfig.configs")
			local util = require("lspconfig.util")

			vim.o.updatetime = 250
			vim.diagnostic.config({
				underline = true,
				virtual_text = false,
				float = {
					border = "rounded",
					source = "if_many",
				},
			})

			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
				end,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP hover docs" })
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

			-- Fallback in case this lspconfig version does not ship qmlls yet.
			if not configs.qmlls then
				configs.qmlls = {
					default_config = {
						cmd = { "qmlls6" },
						filetypes = { "qml", "qmljs" },
						root_dir = util.root_pattern(".git"),
						single_file_support = true,
					},
				}
			end

			lspconfig.qmlls.setup({
				cmd = { "qmlls6" },
			})
		end,
	},
}
