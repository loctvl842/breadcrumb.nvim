## 📦 Installation

```lua
use("loctvl842/breadcrumb.nvim", requires = {"nvim-tree/nvim-web-devicons"})
```

## ⚙️ Configuration

```lua
require("breadcrumb").setup({
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
})
```

To have **breadcrumb**, it must be attached to lsp server.

Example:
```lua
local breadcrumb = require("breadcrumb")

local on_attach = function(client, bufnr)
    ...
    if client.server_capabilities.documentSymbolProvider then
        breadcrumb.attach(client, bufnr)
    end
    ...
end
```

## 🚀 Usage
- We can turn on `breadcrumb` by put this in the config file:
```lua
require("breadcrumb").init()
```
- Recommend using method `get_breadcrumb()` combine with status line plugin for example `lualine`
```lua
local breadcrumb = function()
	local breadcrumb_status_ok, breadcrumb = pcall(require, "breadcrumb")
	if not breadcrumb_status_ok then
		return
	end
	return breadcrumb.get_breadcrumb()
end

local config = {
	winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { breadcrumb },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { breadcrumb },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
}

lualine.setup(config)
```

## Command
- `BreadcrumbEnable` command to enable `breadcrumb`
- `BreadcrumbDisable` command to disable `breadcrumb`
