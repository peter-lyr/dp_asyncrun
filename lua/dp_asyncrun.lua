-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/03 21:28:06 星期三

local M = {}

function M.notify_on_open(win)
  local buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_win_set_option(win, 'concealcursor', 'nvic')
  vim.api.nvim_win_set_option(win, 'conceallevel', 3)
end

function M.notify_info(message)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'info', {
    title = title,
    animate = false,
    on_open = M.notify_on_open,
    timeout = 1000 * 8,
  })
end

M.dp_asyncrun_done_changed = nil

function M.notify_qflist()
  local lines = {}
  local qflist = vim.deepcopy(M.qflist)
  for _, i in ipairs(qflist) do
    lines[#lines + 1] = i.text
  end
  if qflist then
    vim.fn.setqflist(qflist)
  end
  M.notify_info(lines)
end

function M.dp_asyncrun_done_default()
  M.qflist = vim.fn.getqflist()
  M.notify_qflist()
  vim.cmd 'au! User AsyncRunStop'
end

function M._au_user_asyncrunstop()
  vim.cmd 'au User AsyncRunStop call v:lua.AsyncRunDone()'
end

function M.dp_asyncrun_done_replace_default(callback)
  if callback then
    AsyncRunDone = function()
      M.dp_asyncrun_done_changed = nil
      callback()
      vim.cmd 'au! User AsyncRunStop'
      AsyncRunDone = M.dp_asyncrun_done_default
    end
    M.dp_asyncrun_done_changed = 1
  end
  M._au_user_asyncrunstop()
end

function M.dp_asyncrun_done_append_default(callback)
  if callback then
    AsyncRunDone = function()
      M.dp_asyncrun_done_changed = nil
      M.dp_asyncrun_done_default()
      callback()
      AsyncRunDone = M.dp_asyncrun_done_default
    end
    M.dp_asyncrun_done_changed = 1
  end
  M._au_user_asyncrunstop()
end

function M.dp_asyncrun_done_default()
  if not M.dp_asyncrun_done_changed then
    AsyncRunDone = M.dp_asyncrun_done_default
    M._au_user_asyncrunstop()
  end
end

return M
