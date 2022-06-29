local redenrer = require("winbar.renderer")

vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }, {
	callback = function()
		redenrer.get_winbar()
	end,
})
