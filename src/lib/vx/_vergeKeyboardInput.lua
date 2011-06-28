vergeclass "_vergeKeyboardInput"
	function _vergeKeyboardInput:__init(scancode)
		self.scancode = scancode
                self.delay = nil
	end
	
	_vergeKeyboardInput._property('pressed',
		function(self)
                    if self.delay and v3.timer < self.delay then
                        return false
                    else
                        return v3.get_key(self.scancode)
                    end
                end,
		function(self, value)
                    v3.set_key(self.scancode, bool(value))
                    delay = {}
                end)
	
	function _vergeKeyboardInput:Unpress()
		self.pressed = false
	end
        
        function _vergeKeyboardInput:Delay(t)
            self.delay = v3.timer + t
        end
	
	function _vergeKeyboardInput:Hook(func)
		v3.HookKey(self.scancode, func)
	end
	
	function _vergeKeyboardInput:__tostring()
		return "verge keyboard input " .. ObjectAttributesToString(self)
	end
