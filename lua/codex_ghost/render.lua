local M = {}

local state = require("codex_ghost.state")

local function safe_del(buf, id)
  if id and vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_del_extmark, buf, state.ns, id)
  end
end

function M.clear(buf)
  local id = state.marks[buf]
  if id then
    safe_del(buf, id)
    state.marks[buf] = nil
  end
end

function M.show(buf, row, col, text, hl_group)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if not text or text == "" then
    M.clear(buf)
    return
  end

  local id = state.marks[buf]
  local opts = {
    id = id,
    virt_text = { { text, hl_group } },
    virt_text_pos = "overlay",
    hl_mode = "combine",
  }

  local new_id = vim.api.nvim_buf_set_extmark(buf, state.ns, row, col, opts)
  state.marks[buf] = new_id
end

return M
