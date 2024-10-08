vim.api.nvim_create_augroup('Hopper', { clear = true })

local Target_line = 0
local Prev_line
local Command_id
local Started = false
local Center_window = false
local Delay = 500

local M = {}

function M.setup(opts)
    if opts.center_window then Center_window = opts.center_window end
    if opts.delay then Delay = opts.delay end
end

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
    Target_line = getTargetHighlight(current_line, first_line, last_line)

    vim.api.nvim_buf_add_highlight(current_buf, -1, hl_group, Target_line - 1, 0, -1)
end

local function on_line_changed()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    if current_line == Target_line then
        vim.api.nvim_buf_clear_highlight(0, -1, 1, -1)
        highlight()
        Prev_line = current_line
    else
        vim.api.nvim_win_set_cursor(0, { Prev_line, 0 })
        if Center_window then vim.cmd("normal! zz") end
        vim.loop.sleep(Delay)
    end
end

local function start()
    Prev_line = vim.api.nvim_win_get_cursor(0)[1]
    Command_id = vim.api.nvim_create_autocmd('CursorMoved', {
        group = 'Hopper',
        callback = function()
            vim.schedule(function()
                on_line_changed()
            end)
        end,
    })
    highlight()
end

local function stop()
    vim.api.nvim_del_autocmd(Command_id)
    vim.api.nvim_buf_clear_highlight(0, -1, 1, -1)
end

function M.toggle()
    if Started then
        stop()
    else
        start()
    end
    Started = not Started
end

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    callback = function()
        if Started then
            stop()
            Started = false
        end
    end
})

return M
