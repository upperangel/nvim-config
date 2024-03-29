return {
	'williamboman/mason.nvim',
	lazy = false,
	dependencies = {
		'neovim/nvim-lspconfig',
		'williamboman/mason-lspconfig.nvim',
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		'hrsh7th/cmp-nvim-lsp',
		'folke/neodev.nvim',
	},
	config = function()
		local lspconfig = require('lspconfig')
		local tools = require('utils.tools')

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend(
			'force',
			vim.lsp.protocol.make_client_capabilities(),
			require('cmp_nvim_lsp').default_capabilities(capabilities)
		)

		require('mason').setup({
			ui = {
				icons = {
					package_installed = '',
					package_pending = '',
					package_uninstalled = '',
				},
			},
		})

		require('neodev').setup({
			override = function(_, library)
				library.enabled = true
				library.plugins = true
			end,
			lspconfig = true,
			pathStruct = true,
		})

		require('mason-lspconfig').setup({
			ensure_installed = tools.lsp,

			handlers = {
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				['lua_ls'] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								completion = {
									callSnippet = 'Replace',
								},
								runtime = {
									version = 'LuaJIT',
								},
								diagnostics = {
									globals = { 'vim' },
									disable = {
										'missing-fields',
									},
								},
								workspace = {
									library = {
										[vim.fn.expand('$VIMRUNTIME/lua')] = true,
										[vim.fn.stdpath('config') .. '/lua'] = true,
									},
								},
								telemetry = {
									enable = false,
								},
							},
						},
					})
				end,
			},
		})
		require('mason-tool-installer').setup({
			ensure_installed = tools.formatters,
			run_on_Start = true,
			start_delay = 200,
		})
	end,
}
