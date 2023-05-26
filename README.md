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

The target pane that text is sent to follows the standard `send-keys` format, so e.g. the second pane in the first window would be denoted as `0.1`. This target pane can be configured initially in the `setup` function shown above, but also on the fly via the provided `configure_target_socket` function, like in the below snippet:
```
:lua require('slimux').configure_target_socket('0.1')
```
