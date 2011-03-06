Columns = {
    field_x = 16,
    field_y = 16,
    field_w = 7,
    field_h = 13,    
    field = nil,
    
    next_x = 200,
    next_y = 50,
    
    num_colors = 3,
    speed = 50,
    score = 0,
    
    font = vx.Font(0),
    colors = {}
}

Columns.play = function()
    if #Columns.colors < 1 then
        Columns.loadImage()
    end
    
    Columns.field = Columns.getClearField()
    current_piece = Columns.getNewPiece()
    next_piece = Columns.getNewPiece()
    
    local lt = vx.clock.timer
    local dt = 0
    local x
    local y
    local accum = 0
    local speed = Columns.speed
    
    while true do
        vx.UpdateControls()
         
        if vx.key.Up.pressed then
            local t = current_piece.colors[1]
            current_piece.colors[1] = current_piece.colors[2]
            current_piece.colors[2] = current_piece.colors[3]
            current_piece.colors[3] = t
            vx.key.Up.pressed = false
        end
        if vx.key.Left.pressed and current_piece.x > 1 then
            if (current_piece.y < 1 or Columns.field[current_piece.x - 1][math.floor(current_piece.y)] == 0)
                and (current_piece.y < 0 or Columns.field[current_piece.x - 1][math.floor(current_piece.y + 1)] == 0)
                and (current_piece.y < -1 or Columns.field[current_piece.x - 1][math.floor(current_piece.y + 2)] == 0)
                then
                current_piece.x = current_piece.x - 1
            end
            vx.key.Left.pressed = false
        end
        if vx.key.Right.pressed and current_piece.x < Columns.field_w then
            if (current_piece.y < 1 or Columns.field[current_piece.x + 1][math.floor(current_piece.y)] == 0)
                and (current_piece.y < 0 or Columns.field[current_piece.x + 1][math.floor(current_piece.y + 1)] == 0)
                and (current_piece.y < -1 or Columns.field[current_piece.x + 1][math.floor(current_piece.y + 2)] == 0)
                then
                current_piece.x = current_piece.x + 1
            end
            vx.key.Right.pressed = false
        end
        
        if vx.key.Down.pressed then
            speed = Columns.speed / 2.5
        else
            speed = Columns.speed
        end
        
        accum = accum + dt
        
        if accum > speed then
            accum = 0
            
            current_piece.y = current_piece.y + 1
            if (current_piece.y + 2 > Columns.field_h) or (Columns.field[current_piece.x][current_piece.y + 2] and Columns.field[current_piece.x][current_piece.y + 2] > 0) then
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
            end
        end
        
        Columns.drawBackground()
        Columns.drawField()
        
        x = Columns.field_x + (current_piece.x - 1) * 16
        y = Columns.field_y + math.floor(current_piece.y - 1) * 16
        Columns.drawPiece(x, y, current_piece, true)
        Columns.drawPiece(Columns.next_x, Columns.next_y, next_piece)
        
        Columns.font:PrintRight(320, 0, tostring(Columns.score))
        
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

Columns.drawPiece = function(x, y, piece, maskoffscreen)
    if maskoffscreen then
        if x >= Columns.field_x and x + 15 < Columns.field_x + (Columns.field_w + 1) * 16 - 1 then
            if y >= Columns.field_y and y < Columns.field_y + (Columns.field_h + 1) * 16 - 1 then Columns.colors[piece.colors[1]]:Blit(x,y) end
            if y + 16 >= Columns.field_y and y + 16 < Columns.field_y + (Columns.field_h + 1) * 16 - 1 then Columns.colors[piece.colors[2]]:Blit(x,y + 16) end
            if y + 32 >= Columns.field_y and y + 32 < Columns.field_y + (Columns.field_h + 1) * 16 - 1 then Columns.colors[piece.colors[3]]:Blit(x,y + 32) end
        end
    else
        Columns.colors[piece.colors[1]]:Blit(x,y)
        Columns.colors[piece.colors[2]]:Blit(x,y + 16)
        Columns.colors[piece.colors[3]]:Blit(x,y + 32)
    end
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
                Columns.colors[Columns.field[x][y]]:Blit(Columns.field_x + ((x - 1) * 16), Columns.field_y + ((y - 1) * 16))
            end
        end
    end
end

Columns.drawBackground = function()
    vx.screen:RectFill(0, 0, vx.screen.width, vx.screen.height, 0)
    vx.screen:Rect(Columns.field_x - 1, Columns.field_y - 1, Columns.field_x + (Columns.field_w * 16), Columns.field_y + (Columns.field_h * 16), vx.RGB(240, 240, 240))
    vx.screen:RectFill(Columns.field_x, Columns.field_y, Columns.field_x + (Columns.field_w * 16) - 1, Columns.field_y + (Columns.field_h * 16) - 1, vx.RGB(10,10,10))
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
            Columns.score = Columns.score + matches
            if math.floor((Columns.score - matches) / 5) < math.floor(Columns.score / 5) and Columns.speed > 15 then
                Columns.speed = Columns.speed - 5
            end
            
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
                
                local t = vx.clock.timer + Columns.speed
                while vx.clock.timer < t do
                    vx.UpdateControls()
                    Columns.drawBackground()
                    Columns.drawField()
                    Columns.drawPiece(Columns.next_x, Columns.next_y, next_piece)
                    Columns.font:PrintRight(320, 0, tostring(Columns.score))
                    vx.ShowPage()
                end
            until not again
        end
    until matches < 1
end

Columns.loadImage = function()
    table.insert(Columns.colors,b64_decode_image("abaaep8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaamdaWmdaWmdaWiaaaiaaaaaaaaaaap8a//8a//8a//8a//8a//8a/WaaaaaaaaaaamdaWiaaaiaaaiaaaiaaaiaaaaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWiaaaiaaaiaaaiaaaiaaaiaaaaaaaaaaap8a//8a//8a/WaaaaaaamdaWmdaWiaaaiaaaiaaaiaaaiaaaiaaaaaaaaaaaaaaaaaaap8a/WaaaaaaamdaWmdaWiaaaiaaaiaaaiaaaiaaamdaWiaaaiaaaaaaaaaaaaaaap8a/WaaaiaaaiaaaiaaaiaaaiaaaiaaaiaaaiaaaiaaamdaWiaaaiaaaaaaaaaaaaaaaaaaaiaaaiaaaiaaaiaaaiaaaiaaaiaaaiaaamdaWmdaWiaaaiaaaaaaaaaaaaaaap8a/WaaaiaaaiaaaiaaamdaWmdaWmdaWmdaWmdaWicaGaaaaaaaaicaGaaaaaaaap8a//8a/WaaaiaaaiaaaaaaamdaWmdaWmdaWicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a/WaaaaaaaaaaaaaaaaaaaicaGicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaaaaaaaaaaicaGaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaaaaaaicaGaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/Waaaaaaap8a//8a//8a//8a//8a//8a//8a/W=="))
    table.insert(Columns.colors,b64_decode_image("abaaep8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaamdaWmdaWmdaWaaa/Waa/Waaaaaaap8a//8a//8a//8a//8a//8a/WaaaaaaaaaaamdaWaaa/Waa/Waa/Waa/Waa/Waaaaaaap8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWaaa/Waa/Waa/Waa/Waa/Waa/Waaaaaaap8a//8a//8a/WaaaaaaamdaWmdaWaaa/Waa/Waa/Waa/Waa/Waa/Waaaaaaaaaaaaaaap8a/WaaaaaaamdaWmdaWaaa/Waa/Waa/Waa/Waa/8daWaaa/Waa/Waaaaaaaaaaap8a/Waaaaaa/Waa/Waa/Waa/Waa/Waa/Waa/Waa/Waa/8daWaaa/Waa/Waaaaaaaaaaaaaaaaaa/Waa/Waa/Waa/Waa/Waa/Waa/Waa/8daWmdaWaaa/Waa/Waaaaaaaaaaap8a/Waaaaaa/Waa/Waa/8daWmdaWmdaWmdaWmdaWicaGaaaaaaaaicaGaaaaaaaap8a//8a/Waaaaaa/Waa/WaaamdaWmdaWmdaWicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a/WaaaaaaaaaaaaaaaaaaaicaGicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaaaaaaaaaaicaGaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaaaaaaicaGaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/Waaaaaaap8a//8a//8a//8a//8a//8a//8a/W=="))
    table.insert(Columns.colors,b64_decode_image("abaaep8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaamdaWmdaWmdaWacaaacaaaaaaaaaap8a//8a//8a//8a//8a//8a/WaaaaaaaaaaamdaWacaaacaaacaaacaaacaaaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWacaaacaaacaaacaaacaaacaaaaaaaaaap8a//8a//8a/WaaaaaaamdaWmdaWacaaacaaacaaacaaacaaacaaaaaaaaaaaaaaaaaap8a/WaaaaaaamdaWmdaWacaaacaaacaaacaaacaamdaWacaaacaaaaaaaaaaaaaap8a/WaaaacaaacaaacaaacaaacaaacaaacaaacaaacaamdaWacaaacaaaaaaaaaaaaaaaaaaacaaacaaacaaacaaacaaacaaacaaacaamdaWmdaWacaaacaaaaaaaaaaaaaap8a/WaaaacaaacaaacaamdaWmdaWmdaWmdaWmdaWicaGaaaaaaaaicaGaaaaaaaap8a//8a/WaaaacaaacaaaaaamdaWmdaWmdaWicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a/WaaaaaaaaaaaaaaaaaaaicaGicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaaaaaaaaaaicaGaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaaaaaaicaGaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/Waaaaaaap8a//8a//8a//8a//8a//8a//8a/W=="))
    table.insert(Columns.colors,b64_decode_image("abaaep8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaamdaWmdaWmdaWicaGicaGaaaaaaaap8a//8a//8a//8a//8a//8a/WaaaaaaaaaaamdaWicaGicaGicaGicaGicaGaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaamdaWmdaWicaGicaGicaGicaGicaGicaGaaaaaaaap8a//8a//8a/WaaaaaaamdaWmdaWicaGicaGicaGicaGicaGicaGaaaaaaaaaaaaaaaap8a/WaaaaaaamdaWmdaWicaGicaGicaGicaGicaGmdaWicaGicaGaaaaaaaaaaaap8a/WaaaicaGicaGicaGicaGicaGicaGicaGicaGicaGmdaWicaGicaGaaaaaaaaaaaaaaaaicaGicaGicaGicaGicaGicaGicaGicaGmdaWmdaWicaGicaGaaaaaaaaaaaap8a/WaaaicaGicaGicaGmdaWmdaWmdaWmdaWmdaWicaGaaaaaaaaicaGaaaaaaaap8a//8a/WaaaicaGicaGaaaamdaWmdaWmdaWicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a/WaaaaaaaaaaaaaaaaaaaicaGicaGaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a/WaaaaaaaaaaaaaaaicaGaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a/Waaaaaaaaaaaaaaaaaaaaaaaaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/WaaaaaaaaaaaicaGaaaap8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a//8a/Waaaaaaap8a//8a//8a//8a//8a//8a//8a/W=="))
end

-- dumb utils

base64_characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/"

function b64_getchar(x) return string.char(base64_characters:byte(x + 1)) end
function b64_getnum(x) if x == "=" then return nil else return string.find(base64_characters,x) - 1 end end

function b64_encode(t)
    local s = ""
    local i
    local max = math.floor(#t / 3)
    local triplet
    
    for i = 1,max do
        triplet = { t[(i-1)*3 + 1], t[(i-1)*3 + 2], t[(i-1)*3 + 3] }
        s = s .. b64_getchar(math.floor(triplet[1] / 4))
        s = s .. b64_getchar(((triplet[1] % 4) * 16) + (math.floor(triplet[2] / 16)))
        s = s .. b64_getchar(((triplet[2] % 16) * 4) + (math.floor(triplet[3] / 64)))
        s = s .. b64_getchar(triplet[3] % 64)
    end
    
    if t[max*3 + 1] then
        triplet = { t[max*3 + 1], t[max*3 + 2], t[max*3 + 3] }
        s = s .. b64_getchar(math.floor(triplet[1] / 4))
        if triplet[2] then
            s = s .. b64_getchar(((triplet[1] % 4) * 16) + (math.floor(triplet[2] / 16)))
            if triplet[3] then
                s = s .. b64_getchar(((triplet[2] % 16) * 4) + (math.floor(triplet[3] / 64)))
                s = s .. b64_getchar(triplet[3] % 64)
            else
                s = s .. b64_getchar(((triplet[2] % 16) * 4))
                s = s .. "="
            end
        else
            s = s .. b64_getchar((triplet[1] % 4) * 16)
            s = s .. "=="
        end
    end
    
    return s
end

function b64_decode(s)
    local t = {}
    local i
    local quad
    local max = math.floor(string.len(s) / 4)
    
    for i = 1,max do
        quad = {
            b64_getnum(string.char(s:byte((i-1)*4 + 1))),
            b64_getnum(string.char(s:byte((i-1)*4 + 2))),
            b64_getnum(string.char(s:byte((i-1)*4 + 3))),
            b64_getnum(string.char(s:byte((i-1)*4 + 4)))
        }
        table.insert(t, (quad[1] * 4) + math.floor(quad[2] / 16))
        if quad[3] then
            table.insert(t, (quad[2] % 16) * 16 + math.floor(quad[3] / 4))
            if quad[4] then
                table.insert(t, (quad[3] % 4) * 64 + quad[4])
            end
        end
    end
    
    return t
end

function b64_encode_image(img)
    local t = {}
    local w = img.width
    local h = img.height
    local x,y
    
    table.insert(t, math.floor(w / 256))
    table.insert(t, math.floor(w % 256))
    table.insert(t, math.floor(h / 256))
    table.insert(t, math.floor(h % 256))
    for y = 0,h-1 do
        for x = 0,w-1 do
            p = img:GetPixel(x,y)
            table.insert(t,vx.GetR(p))
            table.insert(t,vx.GetG(p))
            table.insert(t,vx.GetB(p))
        end
    end
    
    print(b64_encode(t))
end

function b64_decode_image(s)
    local data = b64_decode(s)
    local w = data[1] * 256 + data[2]
    local h = data[3] * 256 + data[4]
    local img = vx.Image(w, h)
    local i = 5
    
    for y = 0,h-1 do
        for x = 0,w-1 do
            img:SetPixel(x,y,vx.RGB(data[i], data[i+1], data[i+2]))
            i = i + 3
        end
    end
    
    return img
end

function print_table(t)
    local s = "{ "
    local i, k, v
    local first = true
    
    for k,v in pairs(t) do
        if first then first = false else s = s .. ", " end
        s = s .. k .. ":" .. v
    end
    s = s .. " }"
    print(s)
end

