vim.api.nvim_create_augroup('Hopper', { clear = true })

local targetLine = 0
local commandId
local started = false

local function getTargetHighlight(current_line, first_line, last_line)
	math.randomseed(os.time())

	local target = math.random(first_line, last_line)

	while target == current_line do
		target = math.random(first_line, last_line)
	end

	return target
end

local function highlight()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local first_line = vim.fn.line('w0')
	local last_line = vim.fn.line('w$')
	local hl_group = "Search"

	last_line = tonumber(last_line)
	first_line = tonumber(first_line)
	current_line = tonumber(current_line)

	targetLine = getTargetHighlight(current_line, first_line, last_line)

	vim.api.nvim_buf_add_highlight(current_buf, -1, hl_group, targetLine - 1, 0, -1)
end


local function onLineChanged()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	if current_line == targetLine then
		vim.api.nvim_buf_clear_highlight(0, -1, 1, -1)
		highlight()
	end
end


local function start()
	commandId = vim.api.nvim_create_autocmd('CursorMoved', {
		group = 'Hopper',
		callback = onLineChanged,
	})
	highlight()
end

local function stop()
	vim.api.nvim_del_autocmd(commandId)
	vim.api.nvim_buf_clear_highlight(0, -1, 1, -1)
end

local function toggle()
	if started then
		stop()
	else
		start()
	end
	started = not started
end

return { toggle = toggle }
