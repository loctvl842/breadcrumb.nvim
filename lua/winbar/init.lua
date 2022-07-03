local redenrer = require("winbar.renderer")
local gps = require("winbar.gps")
local icons = require("winbar.icons")
local utils = require("winbar.utils")
local space = ""
if vim.fn.has("mac") == 1 then
	space = " "
end

local M = {}

local default_config = {
	disable_icons = false, -- Setting it to true will disable all icons

	icons = {
		["class-name"] = "%#CmpItemKindClass#" .. icons.kind.Class .. "%*" .. space, -- Classes and class-like objects
		["function-name"] = "%#CmpItemKindFunction#" .. icons.kind.Function .. "%*" .. space, -- Functions
		["method-name"] = "%#CmpItemKindMethod#" .. icons.kind.Method .. "%*" .. space, -- Methods (functions inside class-like objects)
		["container-name"] = "%#CmpItemKindProperty#" .. icons.type.Object .. "%*" .. space, -- Containers (example: lua tables)
		["tag-name"] = "%#CmpItemKindKeyword#" .. icons.misc.Tag .. "%*" .. " ", -- Tags (example: html tags)
		["mapping-name"] = "%#CmpItemKindProperty#" .. icons.type.Object .. "%*" .. space,
		["sequence-name"] = "%#CmpItemKindProperty#" .. icons.type.Array .. "%*" .. space,
		["null-name"] = "%#CmpItemKindField#" .. icons.kind.Field .. "%*" .. space,
		["boolean-name"] = "%#CmpItemKindValue#" .. icons.type.Boolean .. "%*" .. space,
		["integer-name"] = "%#CmpItemKindValue#" .. icons.type.Number .. "%*" .. space,
		["float-name"] = "%#CmpItemKindValue#" .. icons.type.Number .. "%*" .. space,
		["string-name"] = "%#CmpItemKindValue#" .. icons.type.String .. "%*" .. space,
		["array-name"] = "%#CmpItemKindProperty#" .. icons.type.Array .. "%*" .. space,
		["object-name"] = "%#CmpItemKindProperty#" .. icons.type.Object .. "%*" .. space,
		["number-name"] = "%#CmpItemKindValue#" .. icons.type.Number .. "%*" .. space,
		["table-name"] = "%#CmpItemKindProperty#" .. icons.ui.Table .. "%*" .. space,
		["date-name"] = "%#CmpItemKindValue#" .. icons.ui.Calendar .. "%*" .. space,
		["date-time-name"] = "%#CmpItemKindValue#" .. icons.ui.Table .. "%*" .. space,
		["inline-table-name"] = "%#CmpItemKindProperty#" .. icons.ui.Calendar .. "%*" .. space,
		["time-name"] = "%#CmpItemKindValue#" .. icons.misc.Watch .. "%*" .. space,
		["module-name"] = "%#CmpItemKindModule#" .. icons.kind.Module .. "%*" .. space,
	},
	separator = icons.ui.ChevronRight,
	depth = 0,
	depth_limit_indicator = "..",
	highlight = "LineNr",
}

function M.setup(user_config)
	local gps_config = {}
	local renderer_config = {
		separator = "%#WinbarSeparator#" .. (user_config.separator or default_config.separator) .. "%*",
	}
	gps_config.icons = default_config.icons

	if not (utils.isempty(user_config) or utils.isempty(user_config.icons)) then
		for item, icon in pairs(user_config.icons) do
			if not utils.isempty(user_config.icons[item]) then
				gps_config.icons[item] = icon
			end
		end
	end

	gps_config.separator = " %#WinbarSeparator#" .. (user_config.separator or default_config.separator) .. "%* "
	gps_config.depth = user_config.depth or default_config.depth
	gps_config.highlight = user_config.highlight or default_config.highlight
	gps.setup(gps_config)
	redenrer.setup(renderer_config)
end

vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }, {
	callback = function()
		redenrer.get_winbar()
	end,
})

return M
