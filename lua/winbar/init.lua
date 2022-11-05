local redenrer = require("winbar.renderer")
local navic = require("winbar.navic")
local utils = require("winbar.utils")
local space = ""
if vim.fn.has("mac") == 1 then
	space = " "
end

local M = {}

local default_config = {
	disabled_filetype = {},
	icons = {
		File = " ",
		Module = " ",
		Namespace = " ",
		Package = " ",
		Class = " ",
		Method = " ",
		Property = " ",
		Field = " ",
		Constructor = " ",
		Enum = "練",
		Interface = "練",
		Function = " ",
		Variable = " ",
		Constant = " ",
		String = " ",
		Number = " ",
		Boolean = "◩ ",
		Array = " ",
		Object = " ",
		Key = " ",
		Null = "ﳠ ",
		EnumMember = " ",
		Struct = " ",
		Event = " ",
		Operator = " ",
		TypeParameter = " ",
	},
	separator = ">",
	depth_limit = 0,
	depth_limit_indicator = "..",
	highlight_group = {
		component = "WinbarText",
		separator = "WinbarSeparator",
	},
}

function M.setup(user_config)
	local navic_config = {}
	local renderer_config = {}

	renderer_config.separator = user_config.separator or default_config.separator
	renderer_config.highlight_group = user_config.highlight_group or default_config.highlight_group
	renderer_config.disabled_filetype = user_config.disabled_filetype or default_config.disabled_filetype

	navic_config.icons = user_config.icons or default_config.icons

	if not (utils.isempty(user_config) or utils.isempty(user_config.icons)) then
		for item, icon in pairs(user_config.icons) do
			if not utils.isempty(user_config.icons[item]) then
				navic_config.icons[item] = icon
			end
		end
	end

	navic_config.separator = user_config.separator or default_config.separator
	navic_config.depth_limit = user_config.depth_limit or default_config.depth_limit
	navic_config.highlight_group = user_config.highlight_group or default_config.highlight_group
	if not utils.isempty(user_config.highlight_group) then
		navic_config.highlight_group = {
			component = user_config.highlight_group.component or default_config.highlight_group.component,
			separator = user_config.highlight_group.separator or default_config.highlight_group.separator,
		}
		renderer_config.highlight = {
			component = user_config.highlight_group.component or default_config.highlight_group.component,
			separator = user_config.highlight_group.separator or default_config.highlight_group.separator,
		}
	end
	navic.setup(navic_config)
	redenrer.setup(renderer_config)
end

function M.attach(client, bufnr)
	navic.attach(client, bufnr)
end

function M.create_winbar()
	vim.api.nvim_create_augroup("_winbar", {})
	vim.api.nvim_create_autocmd(
		{ "CursorMoved", "CursorHold", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost", "TabClosed" },
		{
			group = "_winbar",
			callback = function()
				redenrer.get_winbar()
			end,
		}
	)
end

M.create_winbar()

return M
