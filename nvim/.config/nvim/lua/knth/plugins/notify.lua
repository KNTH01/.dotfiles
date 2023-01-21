vim.notify = require("notify")

-- Debug Notification
-- (value, context_message)
DN = function(v, cm)
  local time = os.date("%H:%M")
  local context_msg = cm or " "
  local msg = context_msg .. " " .. time
  require("notify")(vim.inspect(v), "debug", { title = { "Debug Output", msg } })
  return v
end
