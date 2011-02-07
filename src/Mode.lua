vergeclass "Mode" do
    ---- class variables and methods
    Mode.list = {}
    Mode.current = nil
    Mode.built = false
    
    function Mode.build_all()
        if Mode.built then return end
        
        for k,v in pairs(Mode.list) do
            Mode.list[k] = v()
            Mode.list[k].name = k
        end
        
        
        Mode.built = true
    end
    
    function Mode.add(name, opt)
        if Mode.built then
            Mode.list[name] = Mode(opt)
        else
            Mode.list[name] = opt
        end
    end
    
    -- constructor
    function Mode:__init(opt)
        self.name = "Generic Mode"
        
        if opt then
            for k,v in pairs(opt) do
                self[k] = v
            end
        end
    end
    
    -- member variables and methods
    function Mode:start()
        if Mode.current and Mode.current.teardown then Mode.current:teardown() end
        vx.mouse.cursor = nil
        vx.mouse.tooltip = nil
        
        Mode.current = self
        if Mode.current and Mode.current.setup then Mode.current:setup() end
    end
    
    -- override these functions in your instances
    Mode.teardown = nil
    Mode.setup = nil
    Mode.render = nil 
end
