tools = {}

Mode.add("Draw", function()
    local t = {}
    
    t.setup = function(self)
        vx.key.G:Hook(function()
            vx.key.G:Unpress()
            self.gridElement:toggle()
        end)
        vx.key.H:Hook(function()
            vx.key.H:Unpress()
            self.hiliteElement:toggle()
        end)
        vx.key.V:Hook(function()
            vx.key.V:Unpress()
            Mode.list.VSP:start()
        end)
        
        self.drawCanvas = UIElement(0, 0)
        self.drawCanvas:setSize(vx.screen.width, vx.screen.height)
        self.drawCanvas:setBackground(nil)
        self.drawCanvas:setBorder(0, nil)
        self.drawCanvas:setCursor(assets.cursors.pencil)
        UI.addElement(self.drawCanvas)
        
        self.gridElement = UIElement(0, 0)
        self.gridElement.render = drawGrid
        self.drawCanvas:setBackground(nil)
        self.drawCanvas:setBorder(0, nil)
        UI.addElement(self.gridElement)
        
        self.hiliteElement = UIElement(0,0)
        self.hiliteElement.render = drawTileHilite
        UI.addElement(self.hiliteElement)
        
        self.tileLeftPreview = UIElement(2, 2)
        self.tileLeftPreview.width = 18;
        self.tileLeftPreview.height = 18;
        self.tileLeftPreview:setCursor(assets.cursors.default)
        self.tileLeftPreview.tooltip = "Open Tile Library"
        self.tileLeftPreview.render = function(self)
            vx.screen:Rect(self.x, self.y, self.x + self.width - 1, self.y + self.height - 1, self.borderColor)
            vx.SetOpacity(50) vx.screen:RectFill(self.x + 1, self.y + 1, self.x + self.width - 2, self.y + self.height - 2, colors.black) vx.SetOpacity(100)
            vx.screen:BlitTile(self.x + 1, self.y + 1, tools.pencil.tileleft)
        end
        UI.addElement(self.tileLeftPreview)
        
        self.tileRightPreview = UIElement(19, 2)
        self.tileRightPreview.width = 18;
        self.tileRightPreview.height = 18;
        self.tileRightPreview:setCursor(assets.cursors.default)
        self.tileRightPreview.tooltip = "Open Tile Library"
        self.tileRightPreview.render = function(self)
            vx.screen:Rect(self.x, self.y, self.x + self.width - 1, self.y + self.height - 1, self.borderColor)
            vx.SetOpacity(50) vx.screen:RectFill(self.x + 1, self.y + 1, self.x + self.width - 2, self.y + self.height - 2, colors.black) vx.SetOpacity(100)
            vx.screen:BlitTile(self.x + 1, self.y + 1, tools.pencil.tileright)
        end
        UI.addElement(self.tileRightPreview)
        
        self.layerControl = UIElement(38, 2)
        self.layerControl:setCursor(assets.cursors.default)
        self.layerControl.height = 10
        self.layerControl.width = 0 -- gets set when rendered since this can fluctuate
        self.layerControl.render = function(self)
            local x = self.x
            local y = self.y
            local w = 8
            local h = 8
            
            --vx.screen:RectFill(x, y, x + w, y + h, colors.white)
            --vx.screen:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.black)
            --assets.fonts.tiny:Print(x + 2, y + 2, '+')
            --
            --x = x + w + 2
            
            for i,v in ipairs(vx.map.renderlist) do
                if v == 'O' then
                    x = x + 2
                    v = 'Ob'
                    w = 14
                elseif v == 'Z' then
                    v = 'Zo'
                    w = 14
                end
                
                w = assets.fonts.tiny:TextWidth(v) + 2
                
                vx.screen:RectFill(x, y, x + w, y + h, colors.white)
                if tools.pencil.currentlayer == i then
                    vx.screen:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.green)
                else
                    vx.screen:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.black)
                end
                assets.fonts.tiny:Print(x + 2, y + 2, v, vx.screen)
                
                x = x + w
            end
            
            self.width = x - self.x
        end
        UI.addElement(self.layerControl)
        
       
        
        local options_element = UIElement(vx.screen.width - 17, 3, assets.icons.options)
        options_element:setCursor(assets.cursors.default)
        options_element:setTooltip("Options")
        UI.addElement(options_element)
        
        if not tools.current then tools.current = tools.pencil end
    end
    
    t.teardown = function(self)
        vx.key.G:Hook("")
        vx.key.H:Hook("")
        vx.key.V:Hook("")
        vx.key.F1:Hook("")
    end
    
    t.render = function(self)
        -- SETUP --
        -- temporary state switches
        local current_tool = tools.current
        local current_cursor = nil -- filled below
        local tooltip = nil
        
        if vx.key.Space.pressed then
            current_tool = tools.hand
        end
        
        -- DRAW --
        -- set up UI
        if current_tool.draw then
            current_cursor, vx.mouse.tooltip = current_tool.draw()
        else
            current_cursor, vx.mouse.tooltip = current_tool.cursor, nil
        end
        
        self.drawCanvas:setCursor(current_cursor)
        
        -- INPUT --    
        -- tool usage
        if vx.mouse.left.pressed and current_tool.left then current_tool.left() end
        if vx.mouse.right.pressed and current_tool.right then current_tool.right() end
        
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
    
    tools = {
        pencil = {
            cursor = assets.cursors.pencil,
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
                
                if UI.mouseIsIn(2, 2, 36, 19) then
                    ui_element = { type='tile', which=0, tooltip="Open Tile Library"}
                end
                
                local x = 38
                local y = 2
                local w = 8
                local h = 8
                
                tools.pencil.composit:RectFill(x, y, x + w, y + h, colors.white)
                tools.pencil.composit:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.black)
                assets.fonts.tiny:Print(x + 2, y + 2, '+', tools.pencil.composit)
                
                if UI.mouseIsIn(x, y, x+w, y+h) then
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
                        w = 14
                    end
                    
                    w = assets.fonts.tiny:TextWidth(v) + 2
                    
                    tools.pencil.composit:RectFill(x, y, x + w, y + h, colors.white)
                    if tools.pencil.currentlayer == i then
                        tools.pencil.composit:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.green)
                    else
                        tools.pencil.composit:RectFill(x + 1, y + 1, x + w - 1, y + h - 1, colors.black)
                    end
                    assets.fonts.tiny:Print(x + 2, y + 2, v, tools.pencil.composit)
                    
                    if UI.mouseIsIn(x, y, x+w, y+h) then
                        ui_element = { type='layer', which=i, tooltip="Select/Options" }
                    end
                    
                    x = x + w
                end
                
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
                    return assets.cursors.default, ui_element.tooltip
                else
                    return assets.cursors.pencil, nil
                end
            end,
            
            left = function()
                if tools.pencil.ui_element then
                    local u = tools.pencil.ui_element
                    if u.type == 'tile' then
                        vx.mouse.left.pressed = false
                        Mode.list.VSP:start()
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
                        Mode.list.VSP:start()
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
            cursor=assets.cursors.hand,
            
            left = function()
                vx.camera.x = vx.camera.x + (vx.mouse.lastx - vx.mouse.x)
                vx.camera.y = vx.camera.y + (vx.mouse.lasty - vx.mouse.y)
            end            
        }
    }
    tools.current = tools.pencil

    return Mode(t)
end)


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
