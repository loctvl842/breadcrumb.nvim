local renderer = require("breadcrumb.renderer")
local navic = require("breadcrumb.navic")
local utils = require("breadcrumb.utils")

local M = {}

local default_config = {
	disabled_filetype = {
		"",
		"help",
	},
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
		component = "BreadcrumbText",
		separator = "BreadcrumbSeparator",
	},
}

local function add_defaultHighlight()
	vim.cmd("highlight BreadcrumbText guifg=#c0c0c0")
	vim.cmd("highlight BreadcrumbSeparator guifg=#c0c0c0")
end

local function setup_command()
	local cmd = vim.api.nvim_create_user_command
	cmd("BreadcrumbEnable", function()
		renderer.enable_breadcrumb()
	end, {})
	cmd("BreadcrumbDisable", function()
		renderer.disable_breadcrumb()
	end, {})
end

function M.setup(user_config)
	default_config = vim.tbl_deep_extend("force", default_config, user_config)
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

function M.create_breadcrumb()
  renderer.create_breadcrumb()
end

function M.get_breadcrumb()
	return renderer.get_breadcrumb()
end

return M
