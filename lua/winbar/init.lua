local redenrer = require("winbar.renderer")
local gps = require("winbar.gps")
local utils = require("winbar.utils")
local space = ""
if vim.fn.has("mac") == 1 then
	space = " "
end

local M = {}

local default_config = {
	disable_icons = false, -- Setting it to true will disable all icons
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
	depth = 0,
	depth_limit_indicator = "..",
	highlight_group = {
		component = "BufferFill",
		separator = "BufferFill",
	},
}

function M.setup(user_config)
	local gps_config = {}
	local renderer_config = {}

	renderer_config.separator = user_config.separator or default_config.separator
	renderer_config.highlight_group = user_config.highlight_group or default_config.highlight_group
	renderer_config.disabled_filetype = user_config.disabled_filetype or default_config.disabled_filetype

	gps_config.icons = user_config.icons or default_config.icons

	if not (utils.isempty(user_config) or utils.isempty(user_config.icons)) then
		for item, icon in pairs(user_config.icons) do
			if not utils.isempty(user_config.icons[item]) then
				gps_config.icons[item] = icon
			end
		end
	end

	gps_config.separator = user_config.separator or default_config.separator
	gps_config.depth = user_config.depth or default_config.depth
	gps_config.highlight_group = user_config.highlight_group or default_config.highlight_group
	if not utils.isempty(user_config.highlight_group) then
		gps_config.highlight_group = {
			component = user_config.highlight_group.component or default_config.highlight_group.component,
			separator = user_config.highlight_group.separator or default_config.highlight_group.separator,
		}
		renderer_config.highlight = {
			component = user_config.highlight_group.component or default_config.highlight_group.component,
			separator = user_config.highlight_group.separator or default_config.highlight_group.separator,
		}
	end
	gps.setup(gps_config)
	redenrer.setup(renderer_config)
end

function M.attach(client, bufnr)
	gps.attach(client, bufnr)
end

vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }, {
	callback = function()
		redenrer.get_winbar()
	end,
})

return M
