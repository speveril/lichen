
function vx.ClearSprites()
    v3.ResetSprites()
end

vergeclass "Sprite" do
	Sprite.FLIP_NONE = 1
	Sprite.FLIP_X = 2
	Sprite.FLIP_Y = 3
	Sprite.FLIP_BOTH = 4

	Sprite.DRAW_ADDITIVE = 1
	Sprite.DRAW_NORMAL = 0
	Sprite.DRAW_SUBTRACTIVE = -1
	
	function Sprite:__init(...)
		local t = {...}	
		
		self.sprite_handle = v3.GetSprite() 
		
		self._image = nil
        self._alpha_map = nil
        self._entity = nil
        
        -- Initialize the sprite's data
        self.x = 0
        self.y = 0
        self.use_screen_coordinates = true
        self.lucent = 0 
        self.draw_mode = vx.Sprite.DRAW_NORMAL
        self.flip_x = false
        self.flip_y = false
        self.silhouette = false
        self.silhouette_color = 0
        self.wait = 0
        self.use_map_layer = false
        self.layer = 0
        self.think_rate = 0
        self.think_callback = ''
        
		if tonumber(t[1]) and tonumber(t[2]) then
            self.x = tonumber(t[1])
            self.y = tonumber(t[2])
			if type(t[3]) == "string" then
				self._image = vx.Image(t[3])
            elseif tonumber(t[3]) then
                self._image = vx.Image(t[3])
			elseif t[3] and t[3].image_handle then
				self._image = t[3]
			end
		elseif type(t[1]) == "string" then
			self._image = vx.Image(t[1])
		elseif t[1] and t[1].image_handle then
			self._image = t[1]
		else
			error("Constructor Sprite(" .. IndexedTypesToString(t) .. ") is not defined.", 2)
		end
		
		if self.image then 
			v3.set_sprite_image(self.sprite_handle, self._image.image_handle)
		end
	end
	
    Sprite._property('x',
        function(self) v3.get_sprite_x(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_x(self.sprite_handle, value)
        end
    )
    Sprite._property('y',
        function(self) v3.get_sprite_y(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_y(self.sprite_handle, value)
        end
    )
    
    Sprite._property('lucent',
        function(self) v3.get_sprite_lucent(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_lucent(self.sprite_handle, value)
        end
    )
    
    Sprite._property('opacity',
        function(self) return 100 - v3.get_sprite_lucent(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_lucent(self.sprite_handle, 100 - value)
        end
    )
    
    Sprite._property('draw_mode',
        function(self) return v3.get_sprite_addsub(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_addsub(self.sprite_handle, value)
        end
    )
    
    Sprite._property('flip_x',
        function(self) return v3.get_sprite_xflip(self.sprite_handle) ~= 0 and true or false end,
        function(self, value)
            v3.set_sprite_xflip(self.sprite_handle, value and 1 or 0)
        end
    )
    
    Sprite._property('flip_y',
        function(self) return v3.get_sprite_yflip(self.sprite_handle) ~= 0 and true or false end,
        function(self, value)
            v3.set_sprite_yflip(self.sprite_handle, value and 1 or 0)
        end
    )
    
    Sprite._property('silhouette',
        function(self) return v3.get_sprite_silhouette(self.sprite_handle) ~= 0 and true or false end,
        function(self, value)
            v3.set_sprite_silhouette(self.sprite_handle, value and 1 or 0)
        end
    )
    
    Sprite._property('silhouette_color',
        function(self) return v3.get_sprite_color(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_color(self.sprite_handle, value)
        end
    )
    
    Sprite._property('use_screen_coordinates',
        function(self) return v3.get_sprite_sc(self.sprite_handle) ~= 0 and true or false end,
        function(self, value)
            v3.set_sprite_sc(self.sprite_handle, value and 1 or 0)
        end
    )
    
    Sprite._property('wait',
        function(self) return v3.get_sprite_wait(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_wait(self.sprite_handle, value)
        end
    )
    
    Sprite._property('use_map_layer',
        function(self) return v3.get_sprite_onmap(self.sprite_handle) ~= 0 and true or false end,
        function(self, value)
            v3.set_sprite_onmap (self.sprite_handle, value and 1 or 0)
        end
    )
    
    Sprite._property('layer',
        function(self) return v3.get_sprite_layer(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_layer(self.sprite_handle, value)
        end
    )
    
    Sprite._property('entity',
        function(self) return self._entity end,
        function(self, ent)
            if type(ent) == 'number' then
                self._entity = vx.Entity(ent)
                v3.set_sprite_ent(self.sprite_handle, ent)
            elseif ent and ent.entity_handle then
                self._entity = ent
                v3.set_sprite_ent(self.sprite_handle, ent.entity_handle)
            elseif not ent then
                self._entity = nil
                v3.set_sprite_ent(self.sprite_handle, 0)
                return
            else
                return
            end
        end
    )
        
    Sprite._property('image',
        function(self) return self._image end,
        function(self, img)
            if type(img) == "string" then
                self._image = vx.Image(img)	
            elseif tonumber(img) then
                self._image = vx.Image(img)	
            elseif img and img.image_handle then
                self._image = img
            elseif not img then
                self._image = nil
                v3.set_sprite_image(self.sprite_handle, 0)
                return
            else
                return
            end
            v3.set_sprite_image(self.sprite_handle, self._image.image_handle)
        end
    )
    
    Sprite._property('alpha_map',
        function(self) return self._alpha_map end,
        function(self, img)
            if type(img) == "string" then
                self._alpha_map = vx.Image(img)	
            elseif tonumber(img) then
                self._alpha_map = vx.Image(img)	
            elseif img and img.image_handle then
                self._alpha_map = img
            elseif not img then
                self._alpha_map = nil
                v3.set_sprite_alphamap(self.sprite_handle, 0)
                return
            else
                return
            end
            v3.set_sprite_alphamap(self.sprite_handle, self._alpha_map.image_handle)
        end
    )
    
    Sprite._property('timer',
        function(self) return v3.get_sprite_timer(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_timer(self.sprite_handle, value)
        end
    )
    
    Sprite._property('think_rate',
        function(self) return v3.get_sprite_thinkrate(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_thinkrate(self.sprite_handle, value)
        end
    )
    
    Sprite._property('think_callback',
        function(self) return v3.get_sprite_thinkproc(self.sprite_handle) end,
        function(self, value)
            v3.set_sprite_thinkproc(self.sprite_handle, value)
        end
    )
    
	function Sprite:Remove()
        print("Trying to remove a sprite...")
        if self.sprite_handle then
            v3.sprite[self.sprite_handle].image = 0
            self.image = nil
            self.sprite_handle = -1
        end
	end
	
	function Sprite:SetPosition(x,y)
		if tonumber(x) and tonumber(y) then
			self.x = tonumber(x)
			self.y = tonumber(y)
        else
            error("Method vx.Sprite:SetPosition(" .. IndexedTypesToString(t) .. ") is not defined.", 2)
		end		
	end

	function Sprite:SetFlip(flip)
		if flip == vx.Sprite.FLIP_X or flip == vx.Sprite.FLIP_BOTH then
			self.flip_x = true
		else
			self.flip_x = false
		end
		
		if flip == vx.Sprite.FLIP_Y or flip == vx.Sprite.FLIP_BOTH then
			self.flip_y = true
		else
			self.flip_y = false
		end
	end
	
	function Sprite:__tostring()
		return "sprite " .. ObjectAttributesToString(self)
	end
end
