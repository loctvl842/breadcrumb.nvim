local utils = require("breadcrumb.utils")

M = {
	active = true,
}

local config = {
	disabled_filetype = {
		"",
		"help",
	},
	separator = ">",
	highlight_group = {
		component = "BreadcrumbText",
		separator = "BreadcrumbSeparator",
	},
}

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config)
end

function M.get_filename()
	local cur_filename = vim.fn.expand("%:t")
	if M.filename == cur_filename then
		return M.filename_output
	end
	M.filename = cur_filename

	local cwd = vim.fn.getcwd()
	local project_dir = vim.split(cwd, "/")
	local project_name = project_dir[#project_dir]
	local root = vim.fn.expand("%:h")

	project_name = string.gsub(project_name, "-", "%%-")
	local i, j = string.find(root, project_name)
	if not utils.isempty(i) then
		root = string.sub(root, i)
	end
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

	if not utils.isempty(cur_filename) then
		local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
			cur_filename,
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
		local hl_filename = "%#" .. config.highlight_group.component .. "#" .. cur_filename .. "%*"
		value = value .. hl_icon .. " " .. hl_filename
		M.filename_output = value
	end
	return value
end

local function get_navic()
	local status_ok, navic = pcall(require, "breadcrumb.navic")
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

function M.disable_breadcrumb()
	if not M.active then
		return
	end
  M.active = false
  local status_ok, _ = pcall(vim.api.nvim_del_augroup_by_name, "_breadcrumb")
  if not status_ok then
    return
  end
	
	vim.api.nvim_set_option_value("winbar", "", { scope = "local" })
end

function M.enable_breadcrumb()
	if M.active then
		return
	end
  M.active = true
	M.create_breadcrumb()
	local breadcrumb_value = M.get_filename()
	vim.api.nvim_set_option_value("winbar", breadcrumb_value, { scope = "local" })
end

function M.get_breadcrumb()
  if not M.active then
    return ""
  end
	local breadcrumb_output = M.get_filename()

	local navic_added = false
	if not utils.isempty(breadcrumb_output) then
		local navic_value = get_navic()
		breadcrumb_output = breadcrumb_output .. " " .. navic_value
		if not utils.isempty(navic_value) then
			navic_added = true
		end
	end

	if not utils.isempty(breadcrumb_output) and utils.get_buf_option("mod") then
		local mod = "%#" .. config.highlight_group.component .. "#" .. "●" .. "%*"
		if navic_added then
			breadcrumb_output = breadcrumb_output .. " " .. mod
		else
			breadcrumb_output = breadcrumb_output .. mod
		end
	end
	return breadcrumb_output
end

local excludes = function()
	if vim.tbl_contains(config.disabled_filetype, vim.bo.filetype) then
		return true
	end
	return false
end

function M.create_breadcrumb()
	vim.api.nvim_create_augroup("_breadcrumb", {})
	vim.api.nvim_create_autocmd({
		"CursorHoldI",
		"CursorHold",
		"BufWinEnter",
		"BufFilePost",
		"InsertEnter",
		"BufWritePost",
		"TabClosed",
	}, {
		group = "_breadcrumb",
		callback = function()
			if excludes() then
				return
			end
			local breadcrumb_value = M.get_breadcrumb()
			local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", breadcrumb_value, { scope = "local" })
			if not status_ok then
				return
			end
		end,
	})
end

return M
