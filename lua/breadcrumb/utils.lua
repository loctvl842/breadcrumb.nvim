local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.get_node_text(node)
	local bufnr = vim.api.nvim_get_current_buf()

	-- We have to remember that end_col is end-exclusive
	local start_row, start_col, end_row, end_col = ts_utils.get_node_range(node)

	if start_row ~= end_row then
		local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
		lines[1] = string.sub(lines[1], start_col + 1)
		-- end_row might be just after the last line. In this case the last line is not truncated.
		if #lines == end_row - start_row + 1 then
			lines[#lines] = string.sub(lines[#lines], 1, end_col)
		end
		return lines
	else
		local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
		-- If line is nil then the line is empty
		return line and { string.sub(line, start_col + 1, end_col) } or {}
	end
end

function M.isempty(s)
	return s == nil or s == ""
end

function M.get_buf_option(opt)
	local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
	if not status_ok then
		return nil
	else
		return buf_option
	end
end

function M.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

return M
