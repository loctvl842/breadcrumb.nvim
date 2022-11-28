## INSTALLATION

```lua
use("loctvl842/breadcrumb.nvim", requires = {"nvim-tree/nvim-web-devicons"})
```

## CONFIGURATION

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
