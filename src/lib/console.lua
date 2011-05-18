console = {
    is_open = false,
    
    current_y = 0,
    target_y = 0,
    velocity = 0;
}

console.toggle = function()
    if console.target_y < 1 or not console.is_open then
        console.target_y = vx.screen.height / 2
        console.velocity = 5
    else
        console.target_y = 0
        console.velocity = -5
    end
    
    if not console.is_open then
        console.is_open = true
        console.loop()
    end
end

console.loop = function()
    local dt = 0
    local _timer = vx.clock.timer
    
    while true do
        dt = vx.clock.timer - _timer
        _timer = vx.clock.timer
        
        vx.Render()
        vx.UpdateControls()
        
        vx.SetOpacity(90)
        vx.screen:RectFill(0, 0, vx.screen.width, console.current_y, 0)
        vx.SetOpacity(100)
        vx.screen:Line(0, console.current_y, vx.screen.width, console.current_y, vx.RGB(255, 255, 255))
        
        console.current_y = console.current_y + (console.velocity * dt)
        if console.velocity > 0 and console.current_y > console.target_y then
            console.current_y = console.target_y
            console.velocity = 0
        elseif console.velocity < 0 and console.current_y < 0 then
            console.velocity = 0
            break
        end
        
        vx.ShowPage()
    end
    
    console.is_open = false
end
