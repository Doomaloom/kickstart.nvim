local M = {}

local uv = vim.loop

local function safe_close(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
end

function M.start(cmd, args, prompt, on_chunk, on_exit)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local stdin = uv.new_pipe(false)

  local handle, pid = uv.spawn(cmd, {
    args = args,
    stdio = { stdin, stdout, stderr },
  }, function(code, signal)
    stdout:read_stop()
    stderr:read_stop()
    safe_close(stdout)
    safe_close(stderr)
    safe_close(stdin)
    safe_close(handle)
    if on_exit then
      on_exit(code, signal)
    end
  end)

  if not handle then
    safe_close(stdout)
    safe_close(stderr)
    safe_close(stdin)
    if on_exit then
      on_exit(-1, 0)
    end
    return nil
  end

  stdout:read_start(function(err, data)
    if err then
      return
    end
    if data and on_chunk then
      on_chunk(data)
    end
  end)

  stderr:read_start(function()
    -- Ignore stderr to avoid noisy UI; callers can add logging if needed.
  end)

  stdin:write(prompt)
  stdin:write("\n")
  stdin:shutdown()

  return {
    handle = handle,
    pid = pid,
    stdout = stdout,
    stderr = stderr,
    stdin = stdin,
  }
end

function M.cancel(proc)
  if not proc then
    return
  end
  if proc.handle and not proc.handle:is_closing() then
    pcall(function()
      proc.handle:kill("sigterm")
    end)
  end
  safe_close(proc.stdout)
  safe_close(proc.stderr)
  safe_close(proc.stdin)
  safe_close(proc.handle)
end

return M
