Mode.add("VSP", function()
    local t = {}
    t.scroll = 0
    
    t.setup = function(self)
        self.tileLeftPreview = UIElement(2, 2)
        self.tileLeftPreview.width = 18;
        self.tileLeftPreview.height = 18;
        self.tileLeftPreview:setCursor(assets.cursors.default)
        self.tileLeftPreview.tooltip = "Close tile library"
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
        self.tileRightPreview.tooltip = "Close tile library"
        self.tileRightPreview.render = function(self)
            vx.screen:Rect(self.x, self.y, self.x + self.width - 1, self.y + self.height - 1, self.borderColor)
            vx.SetOpacity(50) vx.screen:RectFill(self.x + 1, self.y + 1, self.x + self.width - 2, self.y + self.height - 2, colors.black) vx.SetOpacity(100)
            vx.screen:BlitTile(self.x + 1, self.y + 1, tools.pencil.tileright)
        end
        UI.addElement(self.tileRightPreview)
        
        self.importButton = UIButton(38, 2, "Import: Image")
        self.importButton.tooltip = "Import tiles from image"
        UI.addElement(self.importButton)
    end
    
    t.render = function(self)
        local bottom = vx.screen.height - ((vx.screen.height - 22) % 16)
        local cursor = assets.cursors.default
        local tooltip = nil
    
        vx.SetOpacity(80)
        vx.screen:RectFill(0, 21, vx.screen.width, bottom, colors.black)
        vx.SetOpacity(100)
        vx.screen:Line(0, 21, vx.screen.width, 21, colors.white)
        vx.screen:Line(0, bottom, vx.screen.width, bottom, colors.white)
        
        local rowsize = (vx.screen.width / 16)
        local screenrows = math.floor((vx.screen.height - 22) / 16)
        local tilerows = math.ceil(vx.map.tilecount / rowsize)
        local x = 0
        local y = 22
        local t = math.floor(self.scroll / 16) * rowsize
        
        for t = t, vx.map.tilecount do
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
        
        if UI.mouseIsIn(0, 22, vx.screen.width, bottom) then
            -- inside the library box
            t = math.floor(self.scroll / 16) * rowsize + (math.floor((vx.mouse.y - 22) / 16) * rowsize) + math.floor(vx.mouse.x / 16)
            
            local str = "Tile " .. t .. "/" .. (vx.map.tilecount - 1)
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
                cursor = assets.cursors.hand
                if vx.mouse.left.pressed or vx.mouse.right.pressed then
                    self.scroll = self.scroll + (vx.mouse.lasty - vx.mouse.y)
                    if self.scroll < 0 then self.scroll = 0 end
                    if self.scroll > (tilerows - screenrows) * 16 then
                        self.scroll = (tilerows - screenrows) * 16
                    end
                end
            else
                if vx.mouse.left.pressed then
                    vx.mouse.left.pressed = false
                    tools.pencil.tileleft = t
                end
                if vx.mouse.right.pressed then
                    vx.mouse.right.pressed = false
                    tools.pencil.tileright = t
                end
            end
        else
            -- outside the library box
            if UI.mouseIsIn(2, 2, 36, 19) then
                if vx.mouse.left.pressed then
                    vx.mouse.left.pressed = false
                    Mode.list.Draw:start()
                end
            end
            
            if vx.mouse.left.pressed and self.importButton:mouseIsIn() then
                --local file = "tmp/oworld_tiles.png" -- get this via file dialog
                local file = Dialog.File("vsp_file", "Choose an image to import...")
                if file then
                    local img = vx.Image(file)
                    local rows = math.floor(img.height / 16)
                    local cols = math.floor(img.width / 16)
                    local num_tiles = rows * cols
                    local new_tileset = vx.Image(16, num_tiles * 16)
                    local i = 0
                    local x, y
                    
                    for y = 0, (rows - 1) do
                        for x = 0, (cols - 1) do
                            img:ImageShell(x * 16, y * 16, 16, 16):FullBlit(0, i * 16, new_tileset)
                            i = i + 1
                        end                    
                    end
                    
                    vx.map:SetTileset(new_tileset)
                    vx.map.tilecount = num_tiles
                end
            end
        end
        
        if vx.key.Escape.pressed or vx.key.V.pressed then
            vx.key.Escape.pressed = false
            vx.key.V.pressed = false
            Mode.list.Draw:start()
        end
        
        vx.mouse.lastx = vx.mouse.x
        vx.mouse.lasty = vx.mouse.y
    end
    
    return Mode(t)
end)

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
