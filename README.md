# slimux.nvim

Send content from the current Neovim buffer to a configurable tmux pane.

## Example setup (and installation)
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
      vim.keymap.set('v', '<leader>r', slimux.send_highlighted_text,
        { desc = 'Send currently highlighted text to configured tmux pane' })
      vim.keymap.set('n', '<leader>r', slimux.send_paragraph_text,
        { desc = 'Send paragraph under cursor to configured tmux pane' })
    end
  }
})
```

The target pane that text is sent to follows the standard `send-keys` format, so e.g. the second pane in the first window would be denoted as `0.1`. This target pane can be configured initially in the `setup` function shown above, but also on the fly via the provided `configure_target_socket` function, like in the below snippet:
```
:lua require('slimux').configure_target_pane('0.1')
```

Additionally, some effort is taken to automatically escape input to send it to its destination intact. The array of escaped strings can be overridden in the above setup function, with the default setting being the below:
```
escaped_strings = { '\\', ';', '"', '$', '\'' }
```

For more detail on specifying tmux command targets, check out the documentation included with the project: https://github.com/tmux/tmux/wiki/Advanced-Use#command-targets

Also, a reminder that pane numbers can be shown via `prefix + q`, which in a standard install will be `C-b + q`.

Additional available functions:
```
send(text)
  Parameters:
    - text: a string of keystrokes that will be sent to the configured panel
  Description:
    This function will send keystrokes to the target pane.
  Note:
    The word 'keystrokes' is used to signify that tmux is not just sending
    regular text, but is performing keystrokes, enabling you to send control
    characters as well (e.g. Ctrl-C in the form of '^C').

send_delayed(text, delay)
  Parameters:
    - text: a string of keystrokes that will be sent to the configured panel
    - delay: a delay between each printed character, specified in milliseconds
  Description:
    This function will have the specified delay between each keystroke sent to
    the target pane.
  Note:
    Same as the above 'send' function. THIS FUNCTION IS NOT ASYNCHRONOUS.
    Neovim will be frozen until the command completes. Be careful with long
    strings and high delays.

send_highlighted_text_with_delay_ms(delay)
  Parameters:
    - delay: a delay between each printed character, specified in milliseconds
  Description:
    This function will send the highlighted text to the configured target, with
    the given delay between each character sent. This can be useful for e.g.
    instructional applications, or a LMGTFY presentational panache.
  Note:
    Same as the above 'send_delayed' function.

send_paragraph_text_with_delay_ms(delay)
  Description:
    Same as the above, but for captured paragraph text.
```

## Compatibility/Support

This project will attempt to support the latest Neovim stable release. Issues or incompatibilities only replicable
in nightly releases, or sufficiently older versions (>2 major versions back) will not be supported.

Thank you for your understanding!
