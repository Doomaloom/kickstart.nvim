local M = {}

local state = require("codex_ghost.state")
local codex = require("codex_ghost.codex")
local render = require("codex_ghost.render")

local defaults = {
    debounce_ms = 300,
    max_lines = 100,
    cmd = "codex",
    args = {},
    stream = true,
    stream_args = { "--stream" },
    non_stream_args = {},
    hl_group = "CodexGhostText",
    prompt_prefix = "Complete the code at cursor. Only output completion text.",
}

local function normalize_first_line(text)
    if not text then
        return ""
    end
    local clean = text:gsub("\r", "")
    return clean:match("([^\n]*)") or ""
end

local function clear_suggestion()
    local buf = state.suggestion_buf
    if buf then
        render.clear(buf)
    end
    state.suggestion = nil
    state.suggestion_buf = nil
    state.suggestion_pos = nil
    state.has_output = false
end

local function cancel_inflight()
    if state.proc then
        codex.cancel(state.proc)
        state.proc = nil
    end
    state.request_id = state.request_id + 1
end

local function stop_timer()
    if state.timer then
        state.timer:stop()
        state.timer:close()
        state.timer = nil
    end
end

local function gather_context(buf)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = row - 1
    local start = math.max(0, line - state.config.max_lines)
    local lines = vim.api.nvim_buf_get_lines(buf, start, line, false)
    -- Only include content up to the cursor, never after it.
    local prefix = vim.api.nvim_buf_get_text(buf, line, 0, line, col, {})[1] or ""
    table.insert(lines, prefix)
    return table.concat(lines, "\n"), line, col
end

local function build_prompt(ctx, filetype)
    return string.format("Filetype: %s\n%s\n\n%s", filetype, state.config.prompt_prefix, ctx)
end

local function start_request()
    local buf = vim.api.nvim_get_current_buf()
    -- hello this is a simple Comment
    if not vim.bo[buf].modifiable then
        return
    end
    if vim.api.nvim_get_mode().mode ~= "i" then
        return
    end

    local ctx, row, col = gather_context(buf)
    if ctx == "" then
        return
    end

    clear_suggestion()
    cancel_inflight()

    local id = state.next_request(buf, row, col)
    local filetype = vim.bo[buf].filetype
    local prompt = build_prompt(ctx, filetype)
    local args = state.config.args
    if state.config.stream then
        args = vim.list_extend(vim.deepcopy(state.config.args), state.config.stream_args)
    end

    local function on_chunk(data)
        if not state.is_current(id) then
            return
        end
        state.has_output = true
        state.suggestion = (state.suggestion or "") .. data
        local first = normalize_first_line(state.suggestion)
        vim.schedule(function()
            if state.is_current(id) then
                render.show(buf, row, col, first, state.config.hl_group)
            end
        end)
    end

    local function on_exit(code)
        if not state.is_current(id) then
            return
        end
        state.proc = nil
        if state.config.stream and not state.has_output and code ~= 0 then
            local fallback_args = vim.list_extend(vim.deepcopy(state.config.args), state.config.non_stream_args)
            state.proc = codex.start(state.config.cmd, fallback_args, prompt, on_chunk, function()
                if state.is_current(id) then
                    state.proc = nil
                end
            end)
            if not state.proc then
                vim.schedule(function()
                    vim.notify("codex_ghost: failed to start Codex CLI (fallback)", vim.log.levels.WARN)
                end)
            end
        end
    end

    state.proc = codex.start(state.config.cmd, args, prompt, on_chunk, on_exit)
    if not state.proc then
        vim.schedule(function()
            vim.notify("codex_ghost: failed to start Codex CLI", vim.log.levels.WARN)
        end)
    end
end

local function on_change()
    -- Cancel any in-flight request and debounce to avoid spamming the CLI.
    clear_suggestion()
    cancel_inflight()
    stop_timer()
    state.timer = vim.loop.new_timer()
    state.timer:start(state.config.debounce_ms, 0, vim.schedule_wrap(function()
        stop_timer()
        start_request()
    end))
end

local function accept_suggestion()
    if state.suggestion and state.suggestion ~= "" then
        local text = state.suggestion
        clear_suggestion()
        cancel_inflight()
        return text
    end
    return "\t"
end

function M.setup(opts)
    state.config = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    vim.api.nvim_set_hl(0, state.config.hl_group, { link = "Comment", default = true })

    local group = vim.api.nvim_create_augroup("CodexGhost", { clear = true })
    vim.api.nvim_create_autocmd("TextChangedI", {
        group = group,
        callback = on_change,
    })
    vim.api.nvim_create_autocmd({ "CursorMovedI", "InsertLeave" }, {
        group = group,
        callback = function()
            clear_suggestion()
            cancel_inflight()
            stop_timer()
        end,
    })

    vim.keymap.set("i", "<Tab>", accept_suggestion, { expr = true, silent = true, noremap = true })
end

return M
