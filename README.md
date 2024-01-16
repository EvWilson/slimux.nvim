# slimux.nvim

Send content from the current Neovim buffer to a configurable tmux pane.

## Example setup and (installation)
Via [lazy](https://github.com/folke/lazy.nvim):
```lua
require("lazy").setup({
  {
    'EvWilson/slimux.nvim',
    config = function()
      local slimux = require('slimux')
      slimux.setup({
        target_socket = slimux.get_tmux_socket(),
        target_pane = string.format('%s.2', slimux.get_tmux_window()),
      })
      vim.keymap.set('v', '<leader>r', ':lua require("slimux").send_highlighted_text()<CR>',
        { desc = 'Send currently highlighted text to configured tmux pane' })
      vim.keymap.set('n', '<leader>r', ':lua require("slimux").send_paragraph_text()<CR>',
        { desc = 'Send paragraph under cursor to configured tmux pane' })
    end
  }
})
```

The target pane that text is sent to follows the standard `send-keys` format, so e.g. the second pane in the first window would be denoted as `0.1`. This target pane can be configured initially in the `setup` function shown above, but also on the fly via the provided `configure_target_socket` function, like in the below snippet:
```
:lua require('slimux').configure_target_pane('0.1')
```

Additionally, some effort is taken to automatically smart-escape input to send it to its destination intact. The array of escaped strings can be overridden in the above setup function, with the default setting being the below:
```
escaped_strings = { '\\', ';', '"', '\'' }
```

For more detail on specifying tmux command targets, check out the documentation included with the project: https://github.com/tmux/tmux/wiki/Advanced-Use#command-targets

Also, a reminder that pane numbers can be shown via `prefix + q`, which in a standard install will be `C-b + q`.
