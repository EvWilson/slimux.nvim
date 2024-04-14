local M = {}

M.__target_socket = ""
M.__target_pane = ""
M.__escaped_strings = { '\\', ';', '"', '$', '\'' }

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

local function capture_highlighted_text()
	local current_buffer = vim.api.nvim_get_current_buf()
	local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(current_buffer, "<"))
	local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(current_buffer, ">"))

	if start_line == end_line and start_col == end_col then
		return nil
	end
	if start_line > end_line or (start_line == end_line and start_col > end_col) then
		start_line, end_line = end_line, start_line
		start_col, end_col = end_col, start_col
	end

	local lines = {}
	for line = start_line, end_line do
		local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
		if line == start_line and line == end_line then
			line_text = string.sub(line_text, start_col + 1, end_col + 1)
		elseif line == start_line then
			line_text = string.sub(line_text, start_col + 1)
		elseif line == end_line then
			line_text = string.sub(line_text, 1, end_col + 1)
		end
		table.insert(lines, line_text)
	end

	return table.concat(lines, "\n")
end

local function capture_paragraph_text()
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

local function escape(text)
	local escapedString = text
	for _, substring in ipairs(M.__escaped_strings) do
		local escapedSubstring = string.gsub(substring, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
		escapedString = string.gsub(escapedString, escapedSubstring, function(match)
			return "\\" .. match
		end)
	end
	return escapedString
end

local function sleep(milliseconds)
	vim.wait(milliseconds, function()
		return false
	end)
end

local function string_to_char_array(str)
	local char_array = {}
	for i = 1, #str do
		char_array[i] = str:sub(i, i)
	end
	return char_array
end

function M.send_delayed(text, delay)
	text = escape(text)
	local flag
	if string.sub(M.__target_socket, 1, 1) == "/" then
		flag = "S"
	else
		flag = "L"
	end
	local arr = string_to_char_array(text)
	for _, char in ipairs(arr) do
		sleep(delay)
		local cmd = string.format('tmux -%s %s send-keys -t %s -- "%s"', flag, M.__target_socket, M.__target_pane, char)
		vim.fn.systemlist(cmd)
	end
	sleep(delay)
	local cmd = string.format('tmux -%s %s send-keys -t %s -- Enter', flag, M.__target_socket, M.__target_pane)
	vim.fn.systemlist(cmd)
end

function M.send(text)
	text = escape(text)
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
	local hl = capture_highlighted_text()
	M.send(hl)
end

function M.send_paragraph_text()
	local para = capture_paragraph_text()
	M.send(para)
end

function M.send_highlighted_text_with_delay_ms(delay)
	local hl = capture_highlighted_text()
	M.send_delayed(hl, delay)
end

function M.send_paragraph_text_with_delay_ms(delay)
	local para = capture_paragraph_text()
	M.send_delayed(para, delay)
end

return M
