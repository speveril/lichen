require "UI-Element"
require "UI-Button"

colors = {}

vergeclass "UI" do
    UI.elements = {}
    
    function UI.setup()
        colors = {
            black = vx.RGB(0, 0, 0),
            white = vx.RGB(255, 255, 255),
            gray = vx.RGB(192, 192, 192),
            green = vx.RGB(0, 192, 0),
            transparent = vx.RGB(255, 0, 255)
        }
    end
    
    function UI.addElement(btn)
        table.insert(UI.elements, btn)
    end
    
    function UI.clear()
        UI.elements = {}
    end
    
    function UI.render()
        local cursor_override
        
        local i
        local v
        
        vx.mouse.tooltip = nil
        
        for i,v in ipairs(UI.elements) do
            if v.visible then
                v:render()
                if v.cursor and v.width and UI.mouseIsIn(v.x, v.y, v.x + v.width, v.y + v.height) then
                    cursor_override = v.cursor
                    if v.tooltip then vx.mouse.tooltip = v.tooltip end
                end
            end
        end
        
        if vx.mouse.tooltip then
            local strw = assets.fonts.tiny:TextWidth(vx.mouse.tooltip)
            x = vx.mouse.x
            y = vx.mouse.y + 7
            w = strw + 2
            h = assets.fonts.tiny.height + 3
            
            if x < 1 then x = 1 end
            if y < 1 then y = 1 end
            if x + w > vx.screen.width - 2 then x = vx.screen.width - w - 2 end
            if y + h > vx.screen.height - 2 then y = vx.screen.height - h - 2 end
            
            vx.SetOpacity(85)
            vx.screen:RectFill(x, y, x + w, y + h, colors.black)
            vx.screen:Rect(x, y, x + w, y + h, colors.gray)
            vx.SetOpacity(100)
            
            assets.fonts.tiny:Print(x + 2, y + 2, vx.mouse.tooltip)
        end
        
        if cursor_override then
            cursor_override:Blit(vx.mouse.x - 8, vx.mouse.y - 8)
        elseif vx.mouse.cursor then
            vx.mouse.cursor:Blit(vx.mouse.x - 8, vx.mouse.y - 8)
        else
            assets.cursors.default:Blit(vx.mouse.x - 8, vx.mouse.y - 8)
        end
    end
    
    function UI.mouseIsIn(x1, y1, x2, y2)
        if vx.mouse.x >= x1 and vx.mouse.x <= x2 and vx.mouse.y >= y1 and vx.mouse.y <= y2 then
            return true
        else
            return false
        end
    end
end

