local M = {}

M.__target_socket = ""
M.__target_pane = ""
M.__escaped_strings = { '\\', ';', '"', '\'' }

function M.setup(config)
	M.__target_socket = config.target_socket
	M.__target_pane = config.target_pane
	if config.escaped_strings ~= nil then
		M.__escaped_strings = config.escaped_strings
	end
end

function M.get_tmux_socket()
	local tmux = vim.env.TMUX ~= nil and vim.env.TMUX or ""
	local socket = vim.split(tmux, ",")[1]
	return socket
end

function M.get_tmux_window()
	return vim.fn.systemlist("tmux display-message -p '#I'")[1]
end

function M.print_config()
	vim.print(string.format("socket: %s, pane: %s", M.__target_socket, M.__target_pane))
end

function M.configure_target_socket(socket)
	M.__target_socket = socket
end

function M.configure_target_pane(pane)
	M.__target_pane = pane
end

function M.configure_escape_strings(strings)
	M.__escaped_strings = strings
end

function M.__capture_highlighted_text()
	local current_buffer = vim.api.nvim_get_current_buf()
	local start_line, _ = unpack(vim.api.nvim_buf_get_mark(current_buffer, "<"))
	local end_line, _ = unpack(vim.api.nvim_buf_get_mark(current_buffer, ">"))
	local highlighted_text = vim.api.nvim_buf_get_lines(current_buffer, start_line - 1, end_line, false)
	highlighted_text = table.concat(highlighted_text, "\n")
	return highlighted_text
end

function M.__capture_paragraph_text()
	local current_buffer = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local start_line, end_line = cursor_line, cursor_line
	while start_line > 0 do
		local line = vim.api.nvim_buf_get_lines(current_buffer, start_line - 1, start_line, false)[1]
		if line == "" then
			break
		end
		start_line = start_line - 1
	end
	local total_lines = vim.api.nvim_buf_line_count(current_buffer)
	while end_line < total_lines do
		local line = vim.api.nvim_buf_get_lines(current_buffer, end_line, end_line + 1, false)[1]
		if line == "" then
			break
		end
		end_line = end_line + 1
	end
	local paragraph_lines = vim.api.nvim_buf_get_lines(current_buffer, start_line, end_line, false)
	local paragraph_text = table.concat(paragraph_lines, "\n")
	return paragraph_text
end

function M.__escape(text)
	local escaped = text
	for _, char in ipairs(M.__escaped_chars) do
		escaped = string.gsub(escaped, char, "\\" .. char)
	end
	return escaped
end

function M.__send(text)
	text = M.__escape(text)
	local flag
	if string.sub(M.__target_socket, 1, 1) == "/" then
		flag = "S"
	else
		flag = "L"
	end
	local cmd = string.format('tmux -%s %s send-keys -t %s -- "%s" Enter', flag, M.__target_socket, M.__target_pane,
		text)
	vim.fn.systemlist(cmd)
end

function M.send_highlighted_text()
	local hl = M.__capture_highlighted_text()
	M.__send(hl)
end

function M.send_paragraph_text()
	local para = M.__capture_paragraph_text()
	M.__send(para)
end

return M
