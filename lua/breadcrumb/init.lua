local redenrer = require("breadcrumb.renderer")
local navic = require("breadcrumb.navic")
local utils = require("breadcrumb.utils")
local space = ""
if vim.fn.has("mac") == 1 then
	space = " "
end

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
		component = "WinbarText",
		separator = "WinbarSeparator",
	},
}

function M.setup(user_config)
	default_config = vim.tbl_deep_extend("force", default_config, user_config)
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
	navic.setup(default_config)
	redenrer.setup(renderer_config)
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
			local breadcrumb_value = redenrer.get_breadcrumb()
			local status_ok, _ = pcall(
				vim.api.nvim_set_option_value,
				"breadcrumb",
				breadcrumb_value,
				{ scope = "local" }
			)
			if not status_ok then
				return
			end
		end,
	})
end

function M.get_breadcrumb()
	return redenrer.get_breadcrumb()
end

return M
