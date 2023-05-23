# slimux.nvim

Send content from the current Neovim buffer to a configurable tmux pane.

Example setup:
```lua
require("slimux").setup({
  target_socket = require("slimux").get_tmux_socket(),
  target_pane = "0.2",
})
vim.keymap.set('v', '<leader>s', ':lua require("slimux").send_highlighted_text()<CR>', { desc = 'Send currently highlighted text to configured tmux pane' })
vim.keymap.set('n', '<leader>s', ':lua require("slimux").send_paragraph_text()<CR>', { desc = 'Send paragraph under cursor to configured tmux pane' })
```
