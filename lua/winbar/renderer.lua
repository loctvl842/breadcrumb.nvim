local utils = require("winbar.utils")

M = {}

local config = {
	disabled_filetype = {
		"",
		"help",
	},
	separator = ">",
	highlight_group = {
		component = "WinbarText",
		separator = "WinbarSeparator",
	},
}

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config)
end

local get_filename = function()
	local cwd = vim.fn.getcwd()
	local project_dir = vim.split(cwd, "/")
	local project_name = project_dir[#project_dir]
	project_name = string.gsub(project_name, "-", "%%-")
	local root = vim.fn.expand("%:h")
	local i, j = string.find(root, project_name)
	if not utils.isempty(i) then
		root = string.sub(root, i)
	end
	local filename = vim.fn.expand("%:t")
	local extension = vim.fn.expand("%:e")
	local value = " "

	if not utils.isempty(root) and root ~= "." then
		local root_parts = utils.split(root, "/")
		for _, rp in ipairs(root_parts) do
			local hl_separator = "%#" .. config.highlight_group.separator .. "#" .. config.separator .. "%*"
			local hl_rp = "%#" .. config.highlight_group.component .. "#" .. rp .. "%*"
			value = value .. hl_rp .. " " .. hl_separator .. " "
		end
	end

	if not utils.isempty(filename) then
		local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
			filename,
			extension,
			{ default = true }
		)

		local hl_group = "FileIconColor" .. extension

		vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
		if utils.isempty(file_icon) then
			file_icon = ""
			file_icon_color = ""
		end
		local hl_icon = "%#" .. hl_group .. "#" .. file_icon .. "%*"
		local hl_filename = "%#" .. config.highlight_group.component .. "#" .. filename .. "%*"
		value = value .. hl_icon .. " " .. hl_filename
	end
	return value
end

local get_navic = function()
	local status_ok, navic = pcall(require, "winbar.navic")
	if not status_ok then
		return ""
	end

	local status_location_ok, navic_location = pcall(navic.get_location, {})
	if not status_location_ok then
		return ""
	end

	if not navic.is_available() or navic_location == "error" then
		return ""
	end
	if utils.isempty(navic_location) then
		return ""
	else
		local hl_separator = "%#" .. config.highlight_group.separator .. "#" .. config.separator .. "%*"
		return hl_separator .. " " .. navic_location
	end
end

local excludes = function()
	if vim.tbl_contains(config.disabled_filetype, vim.bo.filetype) then
		if vim.bo.filetype ~= "neo-tree" then
			vim.api.nvim_set_option_value("winbar", nil, { scope = "local" })
		end
		return true
	end
	return false
end

M.get_winbar = function()
	if excludes() then
		return
	end
	local value = get_filename()

	local navic_added = false
	if not utils.isempty(value) then
		local navic_value = get_navic()
		value = value .. " " .. navic_value
		if not utils.isempty(navic_value) then
			navic_added = true
		end
	end

	if not utils.isempty(value) and utils.get_buf_option("mod") then
		local mod = "%#" .. config.highlight_group.component .. "#" .. "●" .. "%*"
		if navic_added then
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
