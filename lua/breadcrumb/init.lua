local renderer = require("breadcrumb.renderer")
local navic = require("breadcrumb.navic")
local utils = require("breadcrumb.utils")

local M = {}
local isBreadcrumb_enabled = true
local isInit = false

local default_config = {
	disabled_filetype = {
		"",
		"help",
	},
	icons = {
		Array = " ",
		Boolean = "蘒",
		Class = " ",
		Color = " ",
		Constant = " ",
		Constructor = " ",
		Enum = " ",
		EnumMember = " ",
		Event = " ",
		Field = " ",
		File = " ",
		Folder = " ",
		Function = " ",
		Interface = " ",
		Key = " ",
		Keyword = " ",
		Method = " ",
		Module = " ",
		Namespace = " ",
		Null = "ﳠ ",
		Number = " ",
		Object = " ",
		Operator = " ",
		Package = " ",
		Property = " ",
		Reference = " ",
		Snippet = " ",
		String = " ",
		Struct = " ",
		Text = " ",
		TypeParameter = " ",
		Unit = " ",
		Variable = " ",
	},
	separator = ">",
	depth_limit = 0,
	depth_limit_indicator = "..",
	highlight_group = {
		component = "BreadcrumbText",
		separator = "BreadcrumbSeparator",
	},
}

local function add_defaultHighlight()
	vim.cmd("highlight BreadcrumbText guifg=#c0c0c0")
	vim.cmd("highlight BreadcrumbSeparator guifg=#c0c0c0")
end

local function disable_breadcrumb()
	if not isBreadcrumb_enabled then
		return
	end
  isBreadcrumb_enabled = false
	local status_ok, _ = pcall(vim.api.nvim_del_augroup_by_name, "_breadcrumb")
	if not status_ok then
		return
	end

	vim.api.nvim_set_option_value("winbar", "", { scope = "local" })
end

local function enable_breadcrumb()
	if isBreadcrumb_enabled then
		return
	end
	isBreadcrumb_enabled = true
  if isInit then
    M.init()
  end
	local breadcrumb_value = renderer.get_filepath()
	vim.api.nvim_set_option_value("winbar", breadcrumb_value, { scope = "local" })
end

local function setup_command()
	local cmd = vim.api.nvim_create_user_command
	cmd("BreadcrumbEnable", function()
		enable_breadcrumb()
	end, {})
	cmd("BreadcrumbDisable", function()
		disable_breadcrumb()
	end, {})
end

function M.setup(user_config)
	default_config = vim.tbl_deep_extend("force", default_config, user_config)
	renderer.active = true
	setup_command()
	add_defaultHighlight()
	local navic_config = {
		icons = default_config.icons,
		separator = default_config.separator,
		depth_limit = default_config.depth_limit,
		depth_limit_indicator = default_config.depth_limit_indicator,
		highlight_group = default_config.highlight_group,
	}
	local renderer_config = {
		disabled_filetype = default_config.disabled_filetype,
		separator = default_config.separator,
		highlight_group = default_config.highlight_group,
	}
	navic.setup(navic_config)
	renderer.setup(renderer_config)
end

function M.attach(client, bufnr)
	navic.attach(client, bufnr)
end

local excludes = function()
	if vim.tbl_contains(default_config.disabled_filetype, vim.bo.filetype) then
		return true
	end
	return false
end

function M.init()
  isInit = true
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
			local breadcrumb_value = renderer.create_breadcrumb()
			local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", breadcrumb_value, { scope = "local" })
			if not status_ok then
				return
			end
		end,
	})
end

function M.get_breadcrumb()
	if not isBreadcrumb_enabled then
		return ""
	end
	return renderer.create_breadcrumb()
end

return M
