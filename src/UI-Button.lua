vergeclass "UIButton"(UIElement) do
    function UIButton:__init(x, y, text)
        local f = assets.fonts.tiny
        local w = f:TextWidth(text) + 2
        local h = f.height + 2
        self.img = vx.Image(w, h)
        self.img:RectFill(0, 0, w, h, colors.transparent)
        f:Print(1, 1, text, self.img)
        super(x, y, self.img)
    end
end