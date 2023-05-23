# slimux.nvim

Send content from the current Neovim buffer to a configurable tmux pane.

Example setup:
```lua
local slimux = require('slimux')
slimux.setup({
  target_socket = slimux.get_tmux_socket(),
  -- Configures slimux to send text to the third pane of the current window
  target_pane = string.format('%s.2', slimux.get_tmux_window()),
})
vim.keymap.set('v', '<leader>r', ':lua require("slimux").send_highlighted_text()<CR>',
  { desc = 'Send currently highlighted text to configured tmux pane' })
vim.keymap.set('n', '<leader>r', ':lua require("slimux").send_paragraph_text()<CR>',
  { desc = 'Send paragraph under cursor to configured tmux pane' })
```
