local M = {}

M.ns = vim.api.nvim_create_namespace("codex_ghost")
M.marks = {}
M.request_id = 0
M.proc = nil
M.timer = nil
M.suggestion = nil
M.suggestion_buf = nil
M.suggestion_pos = nil
M.has_output = false
M.config = {}

function M.next_request(buf, row, col)
  M.request_id = M.request_id + 1
  M.suggestion = ""
  M.suggestion_buf = buf
  M.suggestion_pos = { row = row, col = col }
  M.has_output = false
  return M.request_id
end

function M.is_current(id)
  return id == M.request_id
end

return M
