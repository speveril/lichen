Dialog = {}
Dialog.state = {}

Dialog.draw = function(x, y, width, height, title)
    local f = assets.fonts.tiny
    local texth = f.height

    vx.SetOpacity(50)
    vx.screen:RectFill(x - 3, y - texth - 6, x + width + 3, y + height + 3, colors.darkgray)
    vx.SetOpacity(100)
    f:Print(x, y - texth - 3, title, vx.screen)
    vx.screen:RectFill(x, y, x + width, y + height, colors.gray)
end