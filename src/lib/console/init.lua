console = {
    is_open = false,
    
    current_y = 0,
    target_y = 0,
    velocity = 0,
    
    buffer_output = "",
    buffer_input = "",
    buffer_cursor = 0,
    buffer_size = 20,
    
    font = vx.Font(0),
    
    key = vx.key.F1,
    version_string = 'VergeConsole v0.01',
    path = string.gsub(string.gsub(string.gsub(debug.getinfo(1,'S').source, "\\", "/"), "init.lua", ""), "@", "")
}

console.font = vx.Font(console.path .. "console_font.png")
console.font:EnableVariableWidth()
console.key:Hook(function()
    console.key:Unpress()
    console.toggle()
end)

console.toggle = function()
    v3.FlushKeyBuffer()
    
    if console.target_y < 1 or not console.is_open then
        console.target_y = console.font.height * console.buffer_size
        console.velocity = 5
    else
        console.target_y = 0
        console.velocity = -5
    end
    
    if not console.is_open then
        console.is_open = true
        console.loop()
    end
end

console.loop = function()
    local dt = 0
    local _timer = vx.clock.timer
    local y
    local input_ln
    local num_lines
    local i
    
    while true do
        dt = vx.clock.timer - _timer
        _timer = vx.clock.timer
        
        vx.Render()
        vx.UpdateControls()
        
        vx.SetOpacity(90)
        vx.screen:RectFill(0, 0, vx.screen.width, console.current_y, 0)
        vx.SetOpacity(100)
        vx.screen:Line(0, console.current_y, vx.screen.width, console.current_y, vx.RGB(255, 255, 255))
        
        console.current_y = console.current_y + (console.velocity * dt)
        if console.velocity > 0 and console.current_y > console.target_y then
            console.current_y = console.target_y
            console.velocity = 0
        elseif console.velocity < 0 and console.current_y < 0 then
            console.velocity = 0
            break
        end
        
        num_lines = 1
        i = string.find(console.buffer_output, '\n', 1, true)
        while i do
            num_lines = num_lines + 1
            i = string.find(console.buffer_output, '\n', i + 1, true)
        end
        
        y = console.current_y - (console.font.height * num_lines)
        console.font:Print(0, y, console.buffer_output)
        
        console.process_input()
        
        input_ln = "> " .. console.buffer_input
        console.font:Print(0, console.current_y - console.font.height, input_ln)
        if math.floor(vx.clock.timer / 15) % 2 == 0 then
            console.font:Print(console.font:TextWidth(string.sub(input_ln, 1, console.buffer_cursor + 2)), console.current_y - console.font.height, "_")
        end
        
        vx.ShowPage()
    end
    
    console.is_open = false
end

console.process_input = function()
    local inp = v3.GetKeyBuffer()
    v3.FlushKeyBuffer()

    if vx.key.Left.pressed then
        vx.key.Left:Unpress()
        console.buffer_cursor = console.buffer_cursor - 1
    end
    if vx.key.Right.pressed then
        vx.key.Right:Unpress()
        console.buffer_cursor = console.buffer_cursor + 1
    end
   

    local b
    local i
    local len = string.len(inp)
    local buf_before = string.sub(console.buffer_input, 1, console.buffer_cursor)
    local buf_after = string.sub(console.buffer_input, console.buffer_cursor + 1)
    local buf_mid = ''
   
    for i = 1,len do
        b = string.byte(inp, i)
        
        if b == 8 then -- backspace
            buf_before = string.sub(buf_before, 1, -2)
            console.buffer_cursor = console.buffer_cursor - 1
        elseif b == 127 then -- delete
            buf_after = string.sub(buf_after, 2)
        elseif b == 10 then -- enter
            console.do_command(buf_before..buf_mid..buf_after)
            buf_before = ""
            buf_mid = ""
            buf_after = ""
        else
            buf_mid = buf_mid .. string.char(string.byte(inp, i))
            console.buffer_cursor = console.buffer_cursor + 1
        end
    end
    
    console.buffer_input = buf_before .. buf_mid .. buf_after
    
    if console.buffer_cursor < 0 then console.buffer_cursor = 0 end
    if console.buffer_cursor > string.len(console.buffer_input) then console.buffer_cursor = string.len(console.buffer_input) end
end

console.output = function(str)
    console.buffer_output = console.buffer_output .. str .. "\n"
end

console.do_command = function(cmd_string)
    console.output("> " .. cmd_string)
    
    local words = {}
    for word in string.gmatch(cmd_string, '([%S]+)') do
        table.insert(words, word)
    end

    local command = words[1]
    table.remove(words, 1)
    
    if console.commands[command] then
        console.commands[command](unpack(words))
    else
        console.output('Command not recognized. Try "help".')
    end
    console.output("")
end

console.commands = {
    help = function()
        console.output('Current commands:')
        --console.output(' set <variable> <new value>')
        console.output(' exit')
    end,
    look = function()
        console.output('You are in a dark room. You are likely to be eaten\nby a grue.')
    end,
    set = function(varname, newval)
        console.output("You want to set '" .. varname .. "' to '" .. newval .. "'")
    end,
    exit = function()
        vx.Exit()
    end
}

console.output('Console enabled. ' .. console.version_string .. '\nType "help" for a list of commands.\n')