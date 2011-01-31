tileLibraryScroll = 0

function tileLibraryRender()
    local bottom = vx.screen.height - ((vx.screen.height - 22) % 16)

    vx.SetOpacity(80)
    vx.screen:RectFill(0, 21, vx.screen.width, bottom, colors.black)
    vx.SetOpacity(100)
    vx.screen:Line(0, 21, vx.screen.width, 21, colors.white)
    vx.screen:Line(0, bottom, vx.screen.width, bottom, colors.white)

    vx.screen:RectFill(2, 2, 36, 19, colors.black)
    vx.screen:Rect(2, 2, 36, 19, colors.white)
    vx.screen:Line(19, 2, 19, 19, colors.white)
    vx.screen:BlitTile(3, 3, tools.pencil.tileleft)
    vx.screen:BlitTile(20, 3, tools.pencil.tileright)

    local x = 0
    local y = 22
    local t = 0
    
    for t = 0, vx.map.tilecount do
        vx.screen:BlitTile(x, y, t)
        x = x + 16
        
        if x >= vx.screen.width then
            y = y + 16
            x = 0
        end
        if y + 16 >= vx.screen.height then
            break
        end
    end
    
    if mouseIsIn(0, 22, vx.screen.width, bottom) then
        -- inside the library box
        local rowsize = (vx.screen.width / 16)
        t = (math.floor((vx.mouse.y - 22) / 16) * rowsize) + math.floor(vx.mouse.x / 16)
        
        local str = "Tile " .. t .. "/" .. vx.map.tilecount
        local strw = assets.fonts.tiny:TextWidth(str)
        
        x = vx.screen.width - 4 - strw
        y = vx.screen.height - assets.fonts.tiny.height - 5
        w = strw + 2
        h = assets.fonts.tiny.height + 3
        
        vx.SetOpacity(50)
        vx.screen:RectFill(x, y, x + w, y + h, colors.black)
        vx.SetOpacity(100)
        assets.fonts.tiny:Print(x + 2, y + 2, str)
        
        drawLibraryHilite()
        
        if vx.key.Space.pressed then
            
        else
            if vx.mouse.left.pressed then
                print("Clicked on " .. t)
                vx.mouse.left.pressed = false
                tools.pencil.tileleft = t
                tools.pencil.tileleftimg = vx.map.tileset:ImageShell(0, 16 * tools.pencil.tileleft, 16, 16)
            end
            if vx.mouse.right.pressed then
                vx.mouse.right.pressed = false
                tools.pencil.tileright = t
                tools.pencil.tilerightimg = vx.map.tileset:ImageShell(0, 16 * tools.pencil.tileright, 16, 16)
            end
        end
    else
        -- outside the library box
    end
    
    if vx.key.Escape.pressed or vx.key.V.pressed then
        vx.key.Escape.pressed = false
        vx.key.V.pressed = false
        switchMode("default")
    end
    
    assets.tools.default:Blit(vx.mouse.x - 8, vx.mouse.y - 8)
    
    vx.mouse.lastx = vx.mouse.x
    vx.mouse.lasty = vx.mouse.y
end

function drawLibraryHilite()
    if vx.mouse.y < 22 then return end

    local x = math.floor(vx.mouse.x / 16) * 16
    local y = math.floor((vx.mouse.y - 22) / 16) * 16 + 22
     
    vx.SetOpacity(10)
    vx.screen:RectFill(x, y, x + 15, y + 15, colors.white)
    vx.SetOpacity(50)
    vx.screen:Rect(x, y, x + 15, y + 15, colors.white)
    vx.SetOpacity(100)
end

