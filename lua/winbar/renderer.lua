local utils = require("winbar.utils")
local icons = require("winbar.icons")

M = {}

local config = {}

local default_config = {
	disabled_filetype = {
		"",
		"help",
	},
	separator = icons.ui.ChevronRight,
	highlight = {
		component = "LineNr",
		separator = "LineNr",
	},
}

function M.setup(user_config)
	if not utils.isempty(user_config) then
		config.separator = user_config.separator or user_config.separator
		config.highlight = default_config.highlight
		config.disabled_filetype = default_config.disabled_filetype
		if not utils.isempty(user_config.disabled_filetype) then
			for _, db_ft in ipairs(user_config.disabled_filetype) do
				table.insert(config.disabled_filetype, db_ft)
			end
		end

		if not utils.isempty(user_config.highlight) then
			local user_highlight = user_config.highlight
			local default_highlight = default_config.highlight
			config.highlight.component = user_highlight.component or default_highlight.component
			config.highlight.separator = user_highlight.separator or default_highlight.separator
		end
	end
end

local get_filename = function()
	local root = vim.fn.expand("%:h")
	local filename = vim.fn.expand("%:t")
	local extension = vim.fn.expand("%:e")
	local value = " "

	if not utils.isempty(root) and root ~= "." then
		local root_parts = utils.split(root, "/")
		for _, rp in ipairs(root_parts) do
			local hl_separator = "%#" .. config.highlight.separator .. "#" .. config.separator .. "%*"
			local hl_rp = "%#" .. config.highlight.component .. "#" .. rp .. "%*"
			value = value .. hl_rp .. " " .. hl_separator .. " "
		end
	end

	if not utils.isempty(filename) then
		local file_icon, file_icon_color = require("dev-icons").get_icon_color(filename, extension, { default = true })

		local hl_group = "FileIconColor" .. extension

		vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
		if utils.isempty(file_icon) then
			file_icon = ""
			file_icon_color = ""
		end
		local hl_icon = "%#" .. hl_group .. "#" .. file_icon .. "%*"
		local hl_filename = "%#" .. config.highlight.component .. "#" .. filename .. "%*"
		value = value .. hl_icon .. " " .. hl_filename
	end
	return value
end

local get_gps = function()
	local status_ok, gps = pcall(require, "winbar.gps")
	if not status_ok then
		return ""
	end

	local status_location_ok, gps_location = pcall(gps.get_location, {})
	if not status_location_ok then
		return ""
	end

	if not gps.is_available() or gps_location == "error" then
		return ""
	end
	if utils.isempty(gps_location) then
		return ""
	else
		local hl_separator = "%#" .. config.highlight.separator .. "#" .. config.separator .. "%*"
		return hl_separator .. " " .. gps_location
	end
end

local excludes = function()
	if vim.tbl_contains(config.disabled_filetype, vim.bo.filetype) then
		vim.opt_local.winbar = ""
		return true
	end
	return false
end

M.get_winbar = function()
	if excludes() then
		return
	end
	local value = get_filename()

	local gps_added = false
	if not utils.isempty(value) then
		local gps_value = get_gps()
		value = value .. " " .. gps_value
		if not utils.isempty(gps_value) then
			gps_added = true
		end
	end

	if not utils.isempty(value) and utils.get_buf_option("mod") then
		local mod = "%#".. config.highlight.component .."#" .. "●" .. "%*"
		if gps_added then
			value = value .. " " .. mod
		else
			value = value .. mod
		end
	end

	local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
	if not status_ok then
		return
	end
end

return M
