----------------------------------------------------------------------------------------------------

require "tile_library"

----------------------------------------------------------------------------------------------------

assets = {}
options = {}
colors = {}

function setup()
    colors = {
        black = vx.RGB(0, 0, 0),
        white = vx.RGB(255, 255, 255),
        gray = vx.RGB(192, 192, 192),
        green = vx.RGB(0, 192, 0),
        transparent = vx.RGB(255, 0, 255)
    }
    
    assets.tools = {
        default = vx.Image("res/ui/default-cursor.png"),
        pencil = vx.Image("res/ui/tool-pencil.png"),
        hand = vx.Image("res/ui/tool-hand.png")
    }
    assets.fonts = {
        system = vx.Font(0),
        default = vx.Font("res/font/console.png"),
        tiny = vx.Font("res/font/5x5.png")
    }
    assets.fonts.default:EnableVariableWidth()
    
    options = {
        grid = true,
        gridsize = 16,
        tilehilite = true
    }
    
    tools = {
        pencil = {
            cursor = assets.tools.pencil,
            tileleft = 0,
            tileright = 0,
            currentlayer = 1,
            ui_element = nil,
            composit = vx.Image(vx.screen.width, vx.screen.height),
            
            draw = function()
                local ui_element = nil
                tools.pencil.composit:Fill(colors.transparent)
                
                tools.pencil.composit:RectFill(2, 2, 36, 19, colors.black)
                tools.pencil.composit:Rect(2, 2, 36, 19, colors.white)
                tools.pencil.composit:Line(19, 2, 19, 19, colors.white)
                tools.pencil.composit:BlitTile(3, 3, tools.pencil.tileleft)
                tools.pencil.composit:BlitTile(20, 3, tools.pencil.tileright)
                
                if mouseIsIn(2, 2, 36, 19) then
                    ui_element = { type='tile', which=0, tooltip="Open Tile Library"}
                end
                
                local x = 38
                local y = 2
                local w = 8
                local h = 8
                
                tools.pencil.composit:RectFill(x, y, x + w, y + h, colors.white)
                tools.pencil.composit:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.black)
                assets.fonts.tiny:Print(x + 2, y + 2, '+', tools.pencil.composit)
                
                if mouseIsIn(x, y, x+w, y+h) then
                    ui_element = { type='layer', which=i, tooltip="Add Layer" }
                end
                
                x = x + w + 2
                
                for i,v in ipairs(vx.map.renderlist) do
                    if v == 'O' then
                        x = x + 2
                        v = 'Ob'
                        w = 14
                    elseif v == 'Z' then
                        v = 'Zo'
                    end
                    
                    w = assets.fonts.tiny:TextWidth(v) + 2
                    
                    tools.pencil.composit:RectFill(x, y, x + w, y + h, colors.white)
                    if tools.pencil.currentlayer == i then
                        tools.pencil.composit:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.green)
                    else
                        tools.pencil.composit:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.black)
                    end
                    assets.fonts.tiny:Print(x + 2, y + 2, v, tools.pencil.composit)
                    
                    if mouseIsIn(x, y, x+w, y+h) then
                        ui_element = { type='layer', which=i, tooltip="Select/Options" }
                    end
                    
                    x = x + w
                end
                
                if not ui_element and options.tilehilite then drawTileHilite() end
                tools.pencil.composit:Blit(0, 0)
                
                local tx = math.floor((vx.mouse.x + vx.camera.x) / 16)
                local ty = math.floor((vx.mouse.y + vx.camera.y) / 16)
                local str = tx .. "," .. ty
                local strw = assets.fonts.tiny:TextWidth(str)
                
                x = vx.screen.width - 4 - strw
                y = vx.screen.height - assets.fonts.tiny.height - 5
                w = strw + 2
                h = assets.fonts.tiny.height + 3
                
                vx.SetOpacity(50)
                vx.screen:RectFill(x, y, x + w, y + h, colors.black)
                vx.SetOpacity(100)
                assets.fonts.tiny:Print(x + 2, y + 2, str)
                
                tools.pencil.ui_element = ui_element
                
                if ui_element then
                    return assets.tools.default, ui_element.tooltip
                else
                    return nil
                end
            end,
            
            left = function()
                if tools.pencil.ui_element then
                    local u = tools.pencil.ui_element
                    if u.type == 'tile' then
                        vx.mouse.left.pressed = false
                        switchMode('tileLibrary')
                    end
                else
                    local tx = math.floor((vx.mouse.x + vx.camera.x) / 16)
                    local ty = math.floor((vx.mouse.y + vx.camera.y) / 16)
                    local lyr = vx.map.renderlist[tools.pencil.currentlayer]
                    
                    if tonumber(lyr) then
                        vx.map:SetTile(tx, ty, tonumber(lyr) - 1, tools.pencil.tileleft)
                    end
                end
            end,
            right = function()
                if tools.pencil.ui_element then
                    local u = tools.pencil.ui_element
                    if u.type == 'tile' then
                        vx.mouse.left.pressed = false
                        switchMode('tileLibrary')
                    end
                else
                    local tx = math.floor((vx.mouse.x + vx.camera.x) / 16)
                    local ty = math.floor((vx.mouse.y + vx.camera.y) / 16)
                    local lyr = vx.map.renderlist[tools.pencil.currentlayer]
                    
                    if tonumber(lyr) then
                        vx.map:SetTile(tx, ty, tonumber(lyr) - 1, tools.pencil.tileright)
                    end
                end
            end
        },
        hand = {
            cursor=assets.tools.hand,
            
            left = function()
                if vx.key.Space.pressed then
                    vx.camera.x = vx.camera.x + (vx.mouse.lastx - vx.mouse.x)
                    vx.camera.y = vx.camera.y + (vx.mouse.lasty - vx.mouse.y)
                end
            end            
        }
    }
    tools.current = tools.pencil
end

----------------------------------------------------------------------------------------------------

current_cursor = nil

function start()
    v3.HookMapLoad("lichenHook_mapLoad")
    v3.HookRetrace("defaultRender")
    
    v3.Map("tmp/oworld.map")
end

function switchMode(mode)
    print("Switching to " .. mode)
    if mode == 'tileLibrary' then
        v3.hookRetrace('tileLibraryRender')
    else
        v3.hookRetrace('defaultRender')
    end
end

----------------------------------------------------------------------------------------------------

function lichenHook_mapLoad()
    print("Map loaded -- " .. vx.map.filename)
    vx.camera:TargetNothing()
    
    vx.map.tilecount = math.floor(vx.map.tileset.height / 16) -- floor() shouldn't be necessary, but just in case
    vx.map.renderlist = v3.curmap.rstring:Explode(",", true)
    table.insert(vx.map.renderlist, 'O')
    table.insert(vx.map.renderlist, 'Z')
end

function defaultRender()
    -- SETUP --
    -- temporary state switches
    local current_tool = tools.current
    local cursor_override = nil
    local tooltip = nil
    if vx.key.Space.pressed then current_tool = tools.hand end

    -- DRAW --
    -- draw UI stuff
    if options.grid then drawGrid() end

    if tools.current and current_tool.draw then
        cursor_override, tooltip = current_tool.draw()
    end

    -- draw the mouse cursor
    if cursor_override then
        drawMouse(cursor_override, tooltip)
    elseif current_tool and current_tool.cursor then
        drawMouse(current_tool.cursor, tooltip)
    else
        drawMouse(assets.tools.default, tooltip)
    end
    
    -- INPUT --    
    -- tool usage
    if vx.mouse.left.pressed and current_tool.left then current_tool.left() end
    if vx.mouse.right.pressed and current_tool.right then current_tool.right() end
    
    -- permanent tool/option switches
    if vx.key.G.pressed then
        vx.key.G.pressed = false
        options.grid = not options.grid
    end
    if vx.key.H.pressed then
        vx.key.H.pressed = false
        options.tilehilite = not options.tilehilite
    end
    
    if tools.current == tools.pencil then
        if vx.key.Ctrl.pressed then
            if vx.key.Z.pressed then
                vx.key.Z.pressed = false
                print("Undo!")
            end
            if vx.key.S.pressed then
                vx.key.S.pressed = false
                
                local filepath = v3.curmap.path
                local pathchunks = filepath:Explode("[\\/]")
                pathchunks[#pathchunks] = v3.curmap.savevsp
                local vsppath = table.concat(pathchunks, "/")
                
                local f = vx.File(filepath, vx.FileMode.Write)
                v3.FileWriteMap(f.file_handle)
                
                f = vx.File(vsppath, vx.FileMode.Write)
                v3.FileWriteVSP(f.file_handle)
            end
        else
            if vx.key.A.pressed then
                vx.key.A.pressed = false
                tools.pencil.tileleft = tools.pencil.tileleft - 1
                if tools.pencil.tileleft < 0 then tools.pencil.tileleft = tools.pencil.tileleft + vx.map.tilecount end
            end
            if vx.key.Z.pressed then
                vx.key.Z.pressed = false
                tools.pencil.tileleft = tools.pencil.tileleft + 1
                if tools.pencil.tileleft >= vx.map.tilecount then tools.pencil.tileleft = tools.pencil.tileleft - vx.map.tilecount end
            end
            if vx.key.S.pressed then
                vx.key.S.pressed = false
                tools.pencil.tileright = tools.pencil.tileright - 1
                if tools.pencil.tileright < 0 then tools.pencil.tileright = tools.pencil.tileright + vx.map.tilecount end
            end
            if vx.key.X.pressed then
                vx.key.X.pressed = false
                tools.pencil.tileright = tools.pencil.tileright + 1
                if tools.pencil.tileright >= vx.map.tilecount then tools.pencil.tileright = tools.pencil.tileright - vx.map.tilecount end
            end
            
            if vx.key.V.pressed then
                vx.key.V.pressed = false
                switchMode("tileLibrary")
            end
            
            if vx.key.Tab.pressed then
                vx.key.Tab.pressed = false
                if vx.key.LeftShift.pressed or vx.key.RightShift.pressed then
                    tools.pencil.currentlayer = tools.pencil.currentlayer - 1
                else
                    tools.pencil.currentlayer = tools.pencil.currentlayer + 1
                end
                
                if tools.pencil.currentlayer > #vx.map.renderlist then tools.pencil.currentlayer = tools.pencil.currentlayer - #vx.map.renderlist end
                if tools.pencil.currentlayer < 1 then tools.pencil.currentlayer = tools.pencil.currentlayer + #vx.map.renderlist end
            end
        end
    end
    
    -- FINISH UP --
    vx.mouse.lastx = vx.mouse.x
    vx.mouse.lasty = vx.mouse.y
end

----------------------------------------------------------------------------------------------------

function mouseIsIn(x1, y1, x2, y2)
    if vx.mouse.x >= x1 and vx.mouse.x <= x2 and vx.mouse.y >= y1 and vx.mouse.y <= y2 then
        return true
    else
        return false
    end
end

----------------------------------------------------------------------------------------------------

function drawGrid()
    local size = options.gridsize
    local ox = -vx.camera.x % size
    local oy = -vx.camera.y % size
    local fx = vx.screen.width
    local fy = vx.screen.height
    
    if ox < 0 then ox = ox + size end
    if oy < 0 then oy = oy + size end
    
    local c = colors.white
    local x = ox
    local y = oy
    
    vx.SetOpacity(10)
    
    while y < fy do
        vx.screen:Line(0, y, fx - 1, y, c)
        y = y + size
    end
        
    while x < fx do
        vx.screen:Line(x, 0, x, fy - 1, c)
        x = x + size
    end
    
    vx.SetOpacity(100)
end

----------------------------------------------------------------------------------------------------

function drawTileHilite()
    local size = options.gridsize
    local tx = math.floor((vx.mouse.x + vx.camera.x) / 16)
    local ty = math.floor((vx.mouse.y + vx.camera.y) / 16)
    
    local x = (tx * size) - vx.camera.x
    local y = (ty * size) - vx.camera.y
    
    local c = colors.white
     
    vx.SetOpacity(10)
    vx.screen:RectFill(x, y, x + 15, y + 15, c)
    vx.SetOpacity(100)
end

----------------------------------------------------------------------------------------------------

function drawMouse(cursor, tooltip)
    cursor:Blit(vx.mouse.x - 8, vx.mouse.y - 8)
    
    if tooltip then
        local strw = assets.fonts.tiny:TextWidth(tooltip)
        x = vx.mouse.x + 10
        y = vx.mouse.y + 3
        w = strw + 2
        h = assets.fonts.tiny.height + 3
        
        if x < 0 then x = 0 end
        if y < 0 then y = 0 end
        if x + w > vx.screen.width - 1 then x = vx.screen.width - w - 1 end
        if y + h > vx.screen.height - 1 then y = vx.screen.height - h - 1 end
        
        vx.SetOpacity(85)
        vx.screen:RectFill(x, y, x + w, y + h, colors.black)
        vx.screen:Rect(x, y, x + w, y + h, colors.gray)
        vx.SetOpacity(100)
        
        assets.fonts.tiny:Print(x + 2, y + 2, tooltip)
    end
end
