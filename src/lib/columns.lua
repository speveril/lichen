Columns = {
    field_x = 0,
    field_y = 0,
    field_w = 7,
    field_h = 13,    
    field = nil,
    
    next_x = 200,
    next_y = 50,
    
    num_colors = 3,
    speed = .03,
    
    colors = {
        vx.RGB(255, 128, 128),
        vx.RGB(128, 255, 128),
        vx.RGB(128, 128, 255),
        vx.RGB(255, 255, 96),
        vx.RGB(96, 255, 255),
        vx.RGB(255, 96, 255)
    }
}

Columns.play = function()
    Columns.field = Columns.getClearField()
    current_piece = Columns.getNewPiece()
    next_piece = Columns.getNewPiece()
    
    local lt = vx.clock.timer
    local dt = 0
    local x
    local y
    
    while true do
        vx.UpdateControls()
         
        if vx.key.Down.pressed then
            current_piece.y = current_piece.y + (dt * Columns.speed * 1.5)
        end
        if vx.key.Up.pressed then
            local t = current_piece.colors[1]
            current_piece.colors[1] = current_piece.colors[2]
            current_piece.colors[2] = current_piece.colors[3]
            current_piece.colors[3] = t
            vx.key.Up.pressed = false
        end
        if vx.key.Left.pressed and current_piece.x > 1 then
            current_piece.x = current_piece.x - 1
            vx.key.Left.pressed = false
        end
        if vx.key.Right.pressed and current_piece.x < Columns.field_w then
            current_piece.x = current_piece.x + 1
            vx.key.Right.pressed = false
        end
        
        if (current_piece.y + 1 > Columns.field_h) or (Columns.field[current_piece.x][math.floor(current_piece.y) + 2] and Columns.field[current_piece.x][math.floor(current_piece.y) + 2] > 0) then
            current_piece.y = current_piece.y - 1
            if current_piece.y < 1 then
                break
            else
                Columns.setBlock(current_piece.x, math.floor(current_piece.y), current_piece.colors[1])
                Columns.setBlock(current_piece.x, math.floor(current_piece.y) + 1, current_piece.colors[2])
                Columns.setBlock(current_piece.x, math.floor(current_piece.y) + 2, current_piece.colors[3])
                Columns.clearMatchedBlocks()
                current_piece = next_piece
                next_piece = Columns.getNewPiece()
            end
        else
            current_piece.y = current_piece.y + (dt * Columns.speed)
        end
        

        vx.screen:RectFill(0, 0, vx.screen.width, vx.screen.height, 0)
        vx.screen:RectFill(Columns.field_x, Columns.field_y, Columns.field_w * 16, Columns.field_h * 16, vx.RGB(10,10,10))
        Columns.drawField()
        
        x = Columns.field_x + (current_piece.x - 1) * 16
        y = Columns.field_y + math.floor(current_piece.y - 1) * 16
        tostring(y) -- what why is this necessary
        Columns.drawPiece(x, y, current_piece)
        Columns.drawPiece(Columns.next_x, Columns.next_y, next_piece)
        
        vx.ShowPage()
        


        dt = vx.clock.timer - lt
        lt = vx.clock.timer
    end
    
    print("You lost!")
end

Columns.getNewPiece = function()
    r = {}
    
    r.x = vx.Random(1, Columns.field_w)
    r.y = -1
    
    r.colors = {}
    table.insert(r.colors, vx.Random(1, Columns.num_colors))
    table.insert(r.colors, vx.Random(1, Columns.num_colors))
    table.insert(r.colors, vx.Random(1, Columns.num_colors))
    
    return r
end

Columns.drawPiece = function(x, y, piece)
    vx.screen:RectFill(x, y, x + 15, y + 15, Columns.colors[piece.colors[1]])
    vx.screen:RectFill(x, y + 16, x + 15, y + 31, Columns.colors[piece.colors[2]])
    vx.screen:RectFill(x, y + 32, x + 15, y + 47, Columns.colors[piece.colors[3]])
end

Columns.getClearField = function()
    local r = {}
    local col = nil
    local x
    local y
    
    for x = 1, Columns.field_w do
        col = {}
        for y = 1, Columns.field_h do
            table.insert(col, 0)
        end
        table.insert(r, col)
    end
    
    return r
end

Columns.drawField = function()
    local x
    local y
   
    for x = 1,Columns.field_w do
        for y = 1,Columns.field_h do
            if Columns.colors[Columns.field[x][y]] then
                vx.screen:RectFill(Columns.field_x + ((x - 1) * 16), Columns.field_y + ((y - 1) * 16), Columns.field_x + ((x - 1) * 16) + 15, Columns.field_y + ((y - 1) * 16) + 15, Columns.colors[Columns.field[x][y]])
            end
        end
    end
end

Columns.setBlock = function(x,y,v)
    Columns.field[x][y] = v
end

Columns.clearMatchedBlocks = function()
    local c = nil
    local matches = 0
    local matched = false
    local again = false
    local offs = 0
    
    repeat
        matches = 0
        for x = 1,Columns.field_w do
            for y = 1,Columns.field_h do
                if Columns.field[x][y] > 0 then
                    c = math.abs(Columns.field[x][y])
                    matched = false
                    
                    if x < Columns.field_w - 1 and math.abs(Columns.field[x+1][y]) == c and math.abs(Columns.field[x+2][y]) == c then
                        offs = 0
                        while Columns.field[x+offs] and math.abs(Columns.field[x+offs][y]) == c do
                            if Columns.field[x+offs][y] > 0 then matches = matches + 1 end
                            Columns.field[x+offs][y] = -c
                            offs = offs + 1
                        end
                    end
                    if y < Columns.field_h - 1 and math.abs(Columns.field[x][y+1]) == c and math.abs(Columns.field[x][y+2]) == c then
                        offs = 0
                        while Columns.field[x][y+offs] and math.abs(Columns.field[x][y+offs]) == c do
                            if Columns.field[x][y+offs] > 0 then matches = matches + 1 end
                            Columns.field[x][y+offs] = -c
                            offs = offs + 1
                        end
                    end
                end
            end
        end
        
        if matches > 0 then
            repeat
                again = false
                for x = 1,Columns.field_w do
                    for y = Columns.field_h,1,-1 do
                        if Columns.field[x][y] < 0 then
                            again = true
                            if Columns.field[x][y - 1] and Columns.field[x][y - 1] >= 0 then
                                Columns.field[x][y] = Columns.field[x][y - 1]
                            end
                            Columns.field[x][y - 1] = 0
                        elseif Columns.field[x][y] == 0 and (y == 1 or Columns.field[x][y - 1] > 0) then
                            if ( y > 1 ) then
                                again = true
                                Columns.field[x][y] = Columns.field[x][y - 1]
                                Columns.field[x][y - 1] = 0
                            else
                                Columns.field[x][y] = 0
                            end
                        end
                    end
                end
            until not again
        end
    until matches < 1
end
