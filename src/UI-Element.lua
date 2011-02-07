vergeclass "UIElement" do
    function UIElement:__init(x, y, img)
        self.x = x
        self.y = y
        self.img = img
        self.background = colors.black
        self.onclick = nil
        self.cursor = nil
        self.tooltip = nil
        self.borderWidth = 1
        self.borderColor = colors.white
        self.visible = true
        
        if img then
            self.width = img.width + self.borderWidth * 2
            self.height = img.height + self.borderWidth * 2
        end
    end
    
    function UIElement:hide() self.visible = false end
    function UIElement:show() self.visible = true end
    function UIElement:toggle() self.visible = not self.visible end
    
    function UIElement:setSize(width, height)
        self.width = width + self.borderWidth * 2
        self.height = height + self.borderWidth * 2
    end
    
    function UIElement:setBorder(width, color)
        self.borderWidth = width
        if self.img then
            self.width = self.img.width + self.borderWidth * 2
            self.height = self.img.height + self.borderWidth * 2
        end
        if color then self.borderColor = color end
    end
    
    function UIElement:setOnClick(f)
        self.onclick = f
    end
    
    function UIElement:setBackground(color, img)
        self.background = color
        self.img = img
    end
    
    function UIElement:setTooltip(tip)
        self.tooltip = tip
    end
    
    function UIElement:setCursor(cursor)
        self.cursor = cursor
    end
    
    function UIElement:render()
        local x = self.x
        local y = self.y
        
        if self.borderWidth then
            local i
            for i = 0, self.borderWidth - 1 do
                vx.screen:Rect(x + i, y + i, x + self.width - 1 - i, y + self.height - 1 - i, self.borderColor)
            end
        end
        
        if self.background then
            vx.screen:RectFill(x + self.borderWidth, y + self.borderWidth, x + self.width - self.borderWidth - 1, y + self.height - self.borderWidth - 1, colors.black)
        end
        
        if self.img then
            self.img:Blit(x + self.borderWidth, y + self.borderWidth)
        end
    end
end