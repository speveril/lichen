Dialog.state.File = {}

Dialog.File = function(which, title)
    if not Dialog.state.File[which] then
        Dialog.state.File[which] = {
            directory = ""
        }
    end
    
    local background = vx.Image(vx.screen.width, vx.screen.height)
    vx.screen:Blit(0, 0, background)
    
    local f = assets.fonts.tinydark
    local f_rev = assets.fonts.tiny
    
    if not title then title = "Choose a file..." end
    local x = 160
    local y = 120
    local w = 320
    local h = 240
    local f_h = f.height
    
    local file = nil
    local done = false
    local file_scroll = 0
    local num_lines = 1 + math.floor((h - f_h - 20) / (f_h + 3))
    local selected = 1
    local file_list = v3.ListFilePattern(Dialog.state.File[which].directory .. "/*.*"):Explode("|")
    if file_list[1] == '.' then table.remove(file_list, 1) end
    table.remove(file_list) -- clip off the blank one at the end
    
    -- fs = file scroll
    local fs_x = x + 69
    local fs_y = y + 3 + (f_h + 4)
    local fs_w = w - 72
    local fs_h = h - 13 - (fs_y - y)

    while true do
        v3.UpdateControls()
        
        background:Blit(0, 0)
        Dialog.draw(x, y, w, h, title)
        
        vx.screen:RectFill(x + 69, y + 3, x + w - 3, y + f_h + 4, colors.white)
        f:Print(x + 4, y + 4 + (f_h + 4) * 0, "Folder:", vx.screen)
        f:Print(x + 70, y + 4 + (f_h + 4) * 0, Dialog.state.File[which].directory .. "/", vx.screen)
        
        vx.screen:RectFill(fs_x, fs_y, fs_x + fs_w, fs_y + fs_h, colors.white)
        f:Print(x + 4, y + 4 + (f_h + 4) * 1, "Filename:", vx.screen)
                
        local line = file_scroll + 1
        for i,v in ipairs(file_list) do
            if line > 0 and line <= num_lines then
                if i == selected then
                    vx.screen:RectFill(x + 69, y + 3 + (f_h + 3) * line, x + w - 3, y + 3 + (f_h + 3) * (line + 1), colors.black)
                    f_rev:Print(x + 70, y + 5 + (f_h + 3) * line, v)
                else
                    f:Print(x + 70, y + 5 + (f_h + 3) * line, v)
                end
            end
            line = line + 1
        end
        
        assets.cursors.default:Blit(vx.mouse.x - 8, vx.mouse.y - 8)
        
        if vx.key.Down.pressed then
            vx.key.Down:Delay(15)
            selected = selected + 1
            if selected > #file_list then selected = #file_list end
            if selected + file_scroll > num_lines then file_scroll = file_scroll end
        end
        if vx.key.Up.pressed then
            vx.key.Up:Delay(15)
            selected = selected - 1
            if selected < 1 then selected = 1 end
            if selected + file_scroll <= 0 then file_scroll = file_scroll end
        end
        if vx.key.PageDown.pressed then
            vx.key.PageDown:Delay(15)
            selected = selected + math.floor(num_lines / 2)
            if selected > #file_list then selected = #file_list end
            while selected + file_scroll > num_lines do file_scroll = file_scroll end
        end
        if vx.key.PageUp.pressed then
            vx.key.PageUp:Delay(15)
            selected = selected - math.floor(num_lines / 2)
            if selected < 1 then selected = 1 end
            while selected + file_scroll <= 0 do file_scroll = file_scroll end
        end
        
        local m_wheel_d = vx.mouse:SampleWheelDelta()
        if m_wheel_d ~= 0 then
            file_scroll = file_scroll + m_wheel_d
            if file_scroll > 0 then file_scroll = 0 end
            if -file_scroll > #file_list - num_lines then file_scroll = -(#file_list - num_lines) end
            if selected + file_scroll < 1 then selected = -file_scroll + 1 end
            if selected + file_scroll > num_lines then selected = -file_scroll + num_lines end
        end
        
        if UI.mouseIsIn(x + 69, y + 3 + (f_h + 4) * 1, x + w - 3, y + h - 13) and vx.mouse.left.pressed then
            local s = math.floor((vx.mouse.y - (y + 3 + (f_h + 3) * 1)) / (f_h + 3)) - file_scroll + 1
            selected = s
        end
        
        if vx.key.Enter.pressed then
            vx.key.Enter:Unpress()
            if file_list[selected] == ".." then
                Dialog.state.File[which].directory = string.gsub(Dialog.state.File[which].directory, "/[^/]+$", "")
            else
                Dialog.state.File[which].directory = Dialog.state.File[which].directory .. "/" .. file_list[selected]
            end
            
            selected = 1
            file_scroll = 0
            
            file_list = v3.ListFilePattern(Dialog.state.File[which].directory .. "/*.*"):Explode("|")
            if #file_list == 1 then
                file = Dialog.state.File[which].directory
                Dialog.state.File[which].directory = string.gsub(Dialog.state.File[which].directory, "/[^/]+$", "")
                break
            else
                if file_list[1] == '.' then table.remove(file_list, 1) end
                table.remove(file_list) -- clip off the blank one at the end
            end
        end
        
        v3.ShowPage()
    end
    
    return file
end