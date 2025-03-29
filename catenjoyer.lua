local MenuLib = {version = "", author = "Etee & Adam"}

function MenuLib.initialize()
    local screen_w, screen_h = render.get_viewport_size()
    local watermark_font = render.create_font("Verdana", 13, 500)
    local keybinds_font = render.create_font("Verdana", 16, 700)
    local indicator_font = render.create_font("Verdana", 16, 700)
    MenuLib.colors = {inactive = {r=255,g=255,b=255}, active = {r=0,g=255,b=0}, accent = {r=0,g=191,b=255}}
    MenuLib.fps = {current=60, frame_count=0, last_update_time=winapi.get_tickcount64()}
    
    MenuLib.key_options = {
        {key = 0x01, name = "Mouse1"},
        {key = 0x02, name = "Mouse2"},
        {key = 0x05, name = "Mouse4"},
        {key = 0x06, name = "Mouse5"},
        {key = 0x20, name = "Space"},
        {key = 0x12, name = "Alt"},
        {key = 0xA4, name = "LShift"},
        {key = 0x43, name = "C"},
        {key = 0x10, name = "Shift"},
        {key = 0x11, name = "Ctrl"}
    }
    
    MenuLib.selected_keys = {
        aimbot = 1,
        triggerbot = 4,
        bhop = 5,
        trigger_indicator = 4,
        bhop_indicator = 5
    }
    
    MenuLib.watermark = {
        ui_x = screen_w - 230,
        ui_y = 10, 
        width = 240, height = 25,
        is_dragging = false, drag_offset_x = 0, drag_offset_y = 0
    }
    
    local text_width, text_height = render.measure_text(keybinds_font, "B-Hop [Space]")
    local bhop_y = (screen_h / 2) + 5
    local keybinds_y = bhop_y + text_height + 10
    
    MenuLib.adams_keybinds = {
        ui_x = 20, ui_y = keybinds_y, ui_width = 128, ui_height = 26,
        is_dragging = false, drag_offset_x = 0, drag_offset_y = 0,
        aimbot_active = false, triggerbot_active = false, bhop_active = false,
        font = render.create_font("Segoe UI", 12, 550),
        visible = true,
        dropdowns = {
            aimbot = false,
            triggerbot = false,
            bhop = false,
            trigger_indicator = false,
            bhop_indicator = false
        }
    }
    
    MenuLib.indicators = {
        triggerbot = {
            x = 20,
            y = (screen_h / 2) - text_height,
            visible = true
        },
        bhop = {
            x = 20,
            y = (screen_h / 2) + 5,
            visible = true
        }
    }
    
    MenuLib.config = {
        menu = {
            x = screen_w - 355, -- Moved 10px left from original (was 345)
            y = screen_h/2-180, 
            width = 345, height = 610,
            isVisible = true, title = "catenjoyer.lua by Etee & Adam", font = render.create_font("Verdana", 12, 400)
        },
        options = {
            {true, "Show Watermark"},
            {true, "Show Crosshair"},
            {true, "Show Keybinds List"},
            {true, "Show Triggerbot Indicator"},
            {true, "Show B-Hop Indicator"}
        }
    }
    
    MenuLib.fonts = {
        menu = MenuLib.config.menu.font,
        watermark = watermark_font,
        keybinds = keybinds_font,
        indicator = indicator_font
    }
    
    MenuLib.draggable = MenuLib.create_draggable("main_menu", MenuLib.config.menu.x, MenuLib.config.menu.y)
    
    -- Config System
    MenuLib.config_system = {
        slots = {
            {name = "Slot 1", keybinds = table.copy(MenuLib.selected_keys)},
            {name = "Slot 2", keybinds = table.copy(MenuLib.selected_keys)},
            {name = "Slot 3", keybinds = table.copy(MenuLib.selected_keys)},
            {name = "Slot 4", keybinds = table.copy(MenuLib.selected_keys)},
            {name = "Slot 5", keybinds = table.copy(MenuLib.selected_keys)}
        },
        current_slot = 1,
        slot_dropdown = false,
        save_mode = false
    }
    
    return MenuLib.config
end

function table.copy(t)
    local u = {}
    for k, v in pairs(t) do u[k] = v end
    return u
end

function MenuLib.create_draggable(name, x, y)
    return {
        name = name, x = tonumber(x) or 0, y = tonumber(y) or 0,
        is_dragging = false, drag_offset_x = 0, drag_offset_y = 0,
        get = function(self) return self.x, self.y end,
        set = function(self, nx, ny) self.x = tonumber(nx) or 0; self.y = tonumber(ny) or 0 end,
        drag = function(self, width, height)
            local mouse_x, mouse_y = input.get_mouse_position()
            mouse_x, mouse_y = tonumber(mouse_x) or 0, tonumber(mouse_y) or 0
            local screen_w, screen_h = render.get_viewport_size()
            local is_hovered = mouse_x >= self.x and mouse_x <= self.x + width and mouse_y >= self.y and mouse_y <= self.y + 30
            if not self.is_dragging and is_hovered and input.is_key_pressed(0x01) then
                self.is_dragging = true; self.drag_offset_x = mouse_x - self.x; self.drag_offset_y = mouse_y - self.y
            end
            if self.is_dragging and not input.is_key_down(0x01) then self.is_dragging = false end
            if self.is_dragging then
                self.x = mouse_x - self.drag_offset_x; self.y = mouse_y - self.drag_offset_y
                self.x = math.max(0, math.min(screen_w - width, self.x))
                self.y = math.max(0, math.min(screen_h - height, self.y))
            end
            return self.x, self.y, is_hovered
        end
    }
end

function MenuLib.update_fps()
    local current_time = winapi.get_tickcount64()
    MenuLib.fps.frame_count = MenuLib.fps.frame_count + 1
    
    if current_time - MenuLib.fps.last_update_time >= 1000 then
        MenuLib.fps.current = MenuLib.fps.frame_count
        MenuLib.fps.frame_count = 0
        MenuLib.fps.last_update_time = current_time
    end
    
    return MenuLib.fps.current
end

function MenuLib.draw_watermark()
    if not MenuLib.config.options[1][1] then return end
    
    local fps = MenuLib.update_fps()
    local username = engine.get_username()
    local viewport_width, viewport_height = render.get_viewport_size()
    local fps_string = string.format("%03d", fps)
    local display_text = "perception.cx | " .. username .. " | " .. fps_string .. " FPS"
    local text_width, text_height = render.measure_text(MenuLib.fonts.watermark, display_text)
    
    local w = MenuLib.watermark
    local mouse_down = input.is_key_down(0x01)
    local mouse_x, mouse_y = input.get_mouse_position()
    
    w.width = text_width + 20
    w.height = text_height + 12
    
    if mouse_down then
        if w.is_dragging then
            w.ui_x = mouse_x - w.drag_offset_x
            w.ui_y = mouse_y - w.drag_offset_y
            
            w.ui_x = math.max(0, math.min(w.ui_x, viewport_width - w.width))
            w.ui_y = math.max(0, math.min(w.ui_y, viewport_height - w.height))
        elseif mouse_x >= w.ui_x and mouse_x <= w.ui_x + w.width and 
               mouse_y >= w.ui_y and mouse_y <= w.ui_y + w.height then
            w.is_dragging = true
            w.drag_offset_x = mouse_x - w.ui_x
            w.drag_offset_y = mouse_y - w.ui_y
        end
    else
        w.is_dragging = false
    end
    
    render.draw_rectangle(w.ui_x, w.ui_y, w.width, w.height, 0, 0, 0, 180, 0, true)
    render.draw_rectangle(w.ui_x, w.ui_y, w.width, 3, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, true)
    
    render.draw_text(MenuLib.fonts.watermark, display_text, w.ui_x + 10, w.ui_y + 6, 255, 255, 255, 255, 0, 0, 0, 0, 0)
end

function MenuLib.draw_crosshair()
    if not MenuLib.config.options[2][1] then return end
    local w, h = render.get_viewport_size()
    local center_x, center_y = (w / 2) + 1, (h / 2) + 1 
    local size, gap, main_thickness, outline_thickness = 5, 2, 2, 1
    local function draw_crosshair_arm(x1, y1, x2, y2)
        render.draw_line(x1, y1, x2, y2, 0, 0, 0, 255, main_thickness + (outline_thickness * 2))
        render.draw_line(x1, y1, x2, y2, 255, 255, 255, 255, main_thickness)
    end
    draw_crosshair_arm(center_x - size - gap, center_y, center_x - gap, center_y)  
    draw_crosshair_arm(center_x + gap, center_y, center_x + size + gap, center_y)  
    draw_crosshair_arm(center_x, center_y - size - gap, center_x, center_y - gap)  
    draw_crosshair_arm(center_x, center_y + gap, center_x, center_y + size + gap)
end

function MenuLib.draw_indicators()
    if MenuLib.config.options[4][1] then
        local trigger_key = MenuLib.key_options[MenuLib.selected_keys.trigger_indicator].key
        local is_trigger_active = input.is_key_down(trigger_key)
        render.draw_text(MenuLib.fonts.indicator, "Triggerbot ["..MenuLib.key_options[MenuLib.selected_keys.trigger_indicator].name.."]", 
                         MenuLib.indicators.triggerbot.x, MenuLib.indicators.triggerbot.y,
                         is_trigger_active and MenuLib.colors.active.r or MenuLib.colors.inactive.r,
                         is_trigger_active and MenuLib.colors.active.g or MenuLib.colors.inactive.g,
                         is_trigger_active and MenuLib.colors.active.b or MenuLib.colors.inactive.b,
                         255, 0, 0, 0, 0, 0)
    end
    
    if MenuLib.config.options[5][1] then
        local bhop_key = MenuLib.key_options[MenuLib.selected_keys.bhop_indicator].key
        local is_bhop_active = input.is_key_down(bhop_key)
        render.draw_text(MenuLib.fonts.indicator, "B-Hop ["..MenuLib.key_options[MenuLib.selected_keys.bhop_indicator].name.."]", 
                         MenuLib.indicators.bhop.x, MenuLib.indicators.bhop.y,
                         is_bhop_active and MenuLib.colors.active.r or MenuLib.colors.inactive.r,
                         is_bhop_active and MenuLib.colors.active.g or MenuLib.colors.inactive.g,
                         is_bhop_active and MenuLib.colors.active.b or MenuLib.colors.inactive.b,
                         255, 0, 0, 0, 0, 0)
    end
end

function MenuLib.draw_adams_keybinds()
    if not MenuLib.config.options[3][1] then return end
    local k = MenuLib.adams_keybinds
    local mouse_down = input.is_key_down(0x01)
    local mouse_x, mouse_y = input.get_mouse_position()
    
    if mouse_down then
        if k.is_dragging then
            k.ui_x, k.ui_y = mouse_x - k.drag_offset_x, mouse_y - k.drag_offset_y
            local viewport_width, viewport_height = render.get_viewport_size()
            k.ui_x = math.max(0, math.min(k.ui_x, viewport_width - k.ui_width))
            k.ui_y = math.max(0, math.min(k.ui_y, viewport_height - k.ui_height))
        elseif mouse_x >= k.ui_x and mouse_x <= k.ui_x + k.ui_width and mouse_y >= k.ui_y and mouse_y <= k.ui_y + k.ui_height then
            k.is_dragging, k.drag_offset_x, k.drag_offset_y = true, mouse_x - k.ui_x, mouse_y - k.ui_y
        end
    else
        k.is_dragging = false
    end
    
    local aimbot_key = MenuLib.key_options[MenuLib.selected_keys.aimbot].key
    local triggerbot_key = MenuLib.key_options[MenuLib.selected_keys.triggerbot].key
    local bhop_key = MenuLib.key_options[MenuLib.selected_keys.bhop].key
    
    k.aimbot_active = input.is_key_down(aimbot_key)
    k.triggerbot_active = input.is_key_down(triggerbot_key)
    k.bhop_active = input.is_key_down(bhop_key)
    
    render.draw_rectangle(k.ui_x, k.ui_y, k.ui_width, k.ui_height, 0, 0, 0, 180, 0, true)
    render.draw_rectangle(k.ui_x, k.ui_y, k.ui_width, 3, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, true)
    
    local keybinds_text = "Keybinds"
    local text_width, text_height = render.measure_text(k.font, keybinds_text)
    render.draw_text(k.font, keybinds_text, k.ui_x + (k.ui_width - text_width) / 2, k.ui_y + (k.ui_height - text_height) / 2, 
                     255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    local _, line_height = render.measure_text(k.font, "Test")
    
    local aimbot_text = " Aimbot ["..MenuLib.key_options[MenuLib.selected_keys.aimbot].name.."] ["..(k.aimbot_active and "active" or "off").."]"
    render.draw_text(k.font, aimbot_text, k.ui_x, k.ui_y + k.ui_height + 2, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    local triggerbot_text = " Triggerbot ["..MenuLib.key_options[MenuLib.selected_keys.triggerbot].name.."] ["..(k.triggerbot_active and "active" or "off").."]"
    render.draw_text(k.font, triggerbot_text, k.ui_x, k.ui_y + k.ui_height + line_height + 3, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    local bhop_text = " B-Hop ["..MenuLib.key_options[MenuLib.selected_keys.bhop].name.."] ["..(k.bhop_active and "active" or "off").."]"
    render.draw_text(k.font, bhop_text, k.ui_x, k.ui_y + k.ui_height + line_height * 2 + 4, 255, 255, 255, 255, 0, 0, 0, 0, 0)
end

function MenuLib.render()
    local menu = MenuLib.config.menu
    if input.is_key_pressed(0x23) then menu.isVisible = not menu.isVisible end
    
    MenuLib.draw_watermark()
    MenuLib.draw_crosshair()
    MenuLib.draw_indicators()
    
    if MenuLib.config.options[3][1] then
        MenuLib.draw_adams_keybinds()
    end
    
    if not menu.isVisible then return end
    
    menu.x, menu.y = MenuLib.draggable:drag(menu.width, menu.height)
    
    render.draw_rectangle(menu.x, menu.y, menu.width, menu.height, 0, 0, 0, 180, 0, true)
    render.draw_rectangle(menu.x, menu.y, menu.width, 3, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, true)
    
    render.draw_text(menu.font, menu.title, menu.x + 10, menu.y + 8, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    local content_y = menu.y + 40
    local option_spacing = 30
    local dropdown_width = 120
    local dropdown_height = 20
    local dropdown_x = menu.x + menu.width - dropdown_width - 20  -- Right-aligned dropdowns
    
    -- Display Options section
    render.draw_text(menu.font, "Display Options", menu.x + 20, content_y, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, 0, 0, 0, 0)
    render.draw_line(menu.x + 20, content_y + 20, menu.x + menu.width - 20, content_y + 20, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 1)
    
    MenuLib.create_checkbox(1, menu.x + 20, content_y + 30)
    MenuLib.create_checkbox(2, menu.x + 20, content_y + 30 + option_spacing)
    
    -- Keybind Settings section
    local keybind_y = content_y + 30 + option_spacing * 2
    render.draw_text(menu.font, "Keybind Settings", menu.x + 20, keybind_y, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, 0, 0, 0, 0)
    render.draw_line(menu.x + 20, keybind_y + 20, menu.x + menu.width - 20, keybind_y + 20, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 1)
    
    MenuLib.create_checkbox(3, menu.x + 20, keybind_y + 30)
    
    local dropdown_y = keybind_y + 30 + option_spacing
    render.draw_text(menu.font, "Aimbot Key:", menu.x + 20, dropdown_y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    local trigger_dropdown_y = dropdown_y + option_spacing
    render.draw_text(menu.font, "Triggerbot Key:", menu.x + 20, trigger_dropdown_y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    local bhop_dropdown_y = trigger_dropdown_y + option_spacing
    render.draw_text(menu.font, "B-Hop Key:", menu.x + 20, bhop_dropdown_y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    -- Indicator Options section
    local indicator_y = bhop_dropdown_y + option_spacing
    render.draw_text(menu.font, "Indicator Options", menu.x + 20, indicator_y, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, 0, 0, 0, 0)
    render.draw_line(menu.x + 20, indicator_y + 20, menu.x + menu.width - 20, indicator_y + 20, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 1)
    
    MenuLib.create_checkbox(4, menu.x + 20, indicator_y + 30)
    
    local trigger_ind_dropdown_y = indicator_y + 30 + option_spacing
    render.draw_text(menu.font, "Trigger Indicator Key:", menu.x + 20, trigger_ind_dropdown_y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    MenuLib.create_checkbox(5, menu.x + 20, trigger_ind_dropdown_y + option_spacing)
    
    local bhop_ind_dropdown_y = trigger_ind_dropdown_y + option_spacing * 2
    render.draw_text(menu.font, "B-Hop Indicator Key:", menu.x + 20, bhop_ind_dropdown_y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    -- Config System section
    local config_y = bhop_ind_dropdown_y + option_spacing * 2
    render.draw_text(menu.font, "Config System", menu.x + 20, config_y, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, 0, 0, 0, 0)
    render.draw_line(menu.x + 20, config_y + 20, menu.x + menu.width - 20, config_y + 20, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 1)
    
    -- Disclaimer text (now properly constrained with word wrapping)
    local disclaimer_text1 = "Note: The Cfg's only get saved"
    local disclaimer_text2 = "while the lua is loaded, unload"
    local disclaimer_text3 = "will erase all your saves"
    local disclaimer_x = menu.x + 25  -- Increased left padding
    local max_width = menu.width - 40  -- Reduced by padding on both sides
    
    -- Measure text and only draw if it fits
    local text1_width = render.measure_text(menu.font, disclaimer_text1)
    local text2_width = render.measure_text(menu.font, disclaimer_text2)
    local text3_width = render.measure_text(menu.font, disclaimer_text3)
    
    if text1_width <= max_width and text2_width <= max_width and text3_width <= max_width then
        render.draw_text(menu.font, disclaimer_text1, disclaimer_x, config_y + 30, 255, 100, 100, 255, 0, 0, 0, 0, 0)
        render.draw_text(menu.font, disclaimer_text2, disclaimer_x, config_y + 45, 255, 100, 100, 255, 0, 0, 0, 0, 0)
        render.draw_text(menu.font, disclaimer_text3, disclaimer_x, config_y + 60, 255, 100, 100, 255, 0, 0, 0, 0, 0)
    else
        -- Fallback if text is too wide
        local short_text1 = "Note: Cfg's saved only while loaded"
        local short_text2 = "Unloading erases all saves"
        render.draw_text(menu.font, short_text1, disclaimer_x, config_y + 30, 255, 100, 100, 255, 0, 0, 0, 0, 0)
        render.draw_text(menu.font, short_text2, disclaimer_x, config_y + 45, 255, 100, 100, 255, 0, 0, 0, 0, 0)
    end
    
    -- Cfg's label before slot dropdown (with increased spacing)
    render.draw_text(menu.font, "Cfg's:", menu.x + 20, config_y + 90, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    -- Current slot display (right-aligned)
    render.draw_rectangle(dropdown_x, config_y + 90, dropdown_width, dropdown_height, 50, 50, 50, 255, 0, true)
    render.draw_text(menu.font, MenuLib.config_system.slots[MenuLib.config_system.current_slot].name, dropdown_x + 5, config_y + 93, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    -- Save/Load buttons (adjusted position)
    local btn_y = config_y + 120
    local btn_width = (menu.width - 60) / 2
    
    -- Save button
    local mouse_x, mouse_y = input.get_mouse_position()
    local save_hovered = mouse_x >= menu.x + 20 and mouse_x <= menu.x + 20 + btn_width and mouse_y >= btn_y and mouse_y <= btn_y + 20
    render.draw_rectangle(menu.x + 20, btn_y, btn_width, 20, save_hovered and 70 or 30, save_hovered and 70 or 30, save_hovered and 70 or 30, 255, 0, true)
    render.draw_text(menu.font, "Save", menu.x + 20 + (btn_width - render.measure_text(menu.font, "Save")) / 2, btn_y + 3, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    -- Load button
    local load_hovered = mouse_x >= menu.x + 40 + btn_width and mouse_x <= menu.x + 40 + btn_width + btn_width and mouse_y >= btn_y and mouse_y <= btn_y + 20
    render.draw_rectangle(menu.x + 40 + btn_width, btn_y, btn_width, 20, load_hovered and 70 or 30, load_hovered and 70 or 30, load_hovered and 70 or 30, 255, 0, true)
    render.draw_text(menu.font, "Load", menu.x + 40 + btn_width + (btn_width - render.measure_text(menu.font, "Load")) / 2, btn_y + 3, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    -- Handle button clicks
    if input.is_key_pressed(0x01) then
        if save_hovered then
            MenuLib.config_system.slots[MenuLib.config_system.current_slot].keybinds = table.copy(MenuLib.selected_keys)
            engine.log("Configuration saved to "..MenuLib.config_system.slots[MenuLib.config_system.current_slot].name, 0, 255, 255, 255)
        elseif load_hovered then
            MenuLib.selected_keys = table.copy(MenuLib.config_system.slots[MenuLib.config_system.current_slot].keybinds)
            engine.log("Configuration loaded from "..MenuLib.config_system.slots[MenuLib.config_system.current_slot].name, 0, 255, 255, 255)
        end
    end
    
    -- Handle slot dropdown interaction (right-aligned)
    local slot_hovered = mouse_x >= dropdown_x and mouse_x <= dropdown_x + dropdown_width and 
                         mouse_y >= config_y + 90 and mouse_y <= config_y + 90 + dropdown_height
    
    if input.is_key_pressed(0x01) then
        if slot_hovered then
            MenuLib.config_system.slot_dropdown = not MenuLib.config_system.slot_dropdown
        elseif MenuLib.config_system.slot_dropdown then
            -- Check if clicking on a slot option
            if mouse_x >= dropdown_x and mouse_x <= dropdown_x + dropdown_width then
                for i = 1, #MenuLib.config_system.slots do
                    local option_y = config_y + 90 + dropdown_height + (i-1) * 20
                    if mouse_y >= option_y and mouse_y <= option_y + 20 then
                        MenuLib.config_system.current_slot = i
                        MenuLib.config_system.slot_dropdown = false
                        break
                    end
                end
            end
            MenuLib.config_system.slot_dropdown = false
        end
    end
    
    -- Draw slot dropdown if open (right-aligned)
    if MenuLib.config_system.slot_dropdown then
        render.draw_rectangle(dropdown_x, config_y + 90 + dropdown_height, dropdown_width, #MenuLib.config_system.slots * 20, 30, 30, 30, 255, 0, true)
        
        for i, slot in ipairs(MenuLib.config_system.slots) do
            local option_y = config_y + 90 + dropdown_height + (i-1) * 20
            local option_hovered = mouse_x >= dropdown_x and mouse_x <= dropdown_x + dropdown_width and 
                                 mouse_y >= option_y and mouse_y <= option_y + 20
            
            render.draw_rectangle(dropdown_x, option_y, dropdown_width, 20, 
                                option_hovered and 70 or 30, 
                                option_hovered and 70 or 30, 
                                option_hovered and 70 or 30, 255, 0, true)
            
            render.draw_text(menu.font, slot.name, dropdown_x + 5, option_y + 3, 255, 255, 255, 255, 0, 0, 0, 0, 0)
        end
    end
    
    -- Keybind dropdowns (right-aligned)
    local dropdowns_to_draw = {}
    
    local function prepare_dropdown(dropdown_type, y_pos, current_selection)
        render.draw_rectangle(dropdown_x, y_pos, dropdown_width, dropdown_height, 50, 50, 50, 255, 0, true)
        render.draw_text(menu.font, MenuLib.key_options[current_selection].name, dropdown_x + 5, y_pos + 3, 255, 255, 255, 255, 0, 0, 0, 0, 0)
        
        local is_hovered = mouse_x >= dropdown_x and mouse_x <= dropdown_x + dropdown_width and 
                          mouse_y >= y_pos and mouse_y <= y_pos + dropdown_height
        
        if input.is_key_pressed(0x01) then
            if is_hovered then
                for k, _ in pairs(MenuLib.adams_keybinds.dropdowns) do
                    MenuLib.adams_keybinds.dropdowns[k] = (k == dropdown_type)
                end
            elseif MenuLib.adams_keybinds.dropdowns[dropdown_type] then
                if mouse_x >= dropdown_x and mouse_x <= dropdown_x + dropdown_width then
                    for i = 1, #MenuLib.key_options do
                        local item_y = y_pos + dropdown_height + (i-1) * 20
                        if mouse_y >= item_y and mouse_y <= item_y + 20 then
                            MenuLib.selected_keys[dropdown_type] = i
                            MenuLib.adams_keybinds.dropdowns[dropdown_type] = false
                            break
                        end
                    end
                end
                MenuLib.adams_keybinds.dropdowns[dropdown_type] = false
            end
        end
        
        if MenuLib.adams_keybinds.dropdowns[dropdown_type] then
            table.insert(dropdowns_to_draw, {
                type = dropdown_type,
                x = dropdown_x,
                y = y_pos,
                width = dropdown_width,
                height = dropdown_height,
                current_selection = current_selection
            })
        end
    end
    
    prepare_dropdown("aimbot", dropdown_y, MenuLib.selected_keys.aimbot)
    prepare_dropdown("triggerbot", trigger_dropdown_y, MenuLib.selected_keys.triggerbot)
    prepare_dropdown("bhop", bhop_dropdown_y, MenuLib.selected_keys.bhop)
    prepare_dropdown("trigger_indicator", trigger_ind_dropdown_y, MenuLib.selected_keys.trigger_indicator)
    prepare_dropdown("bhop_indicator", bhop_ind_dropdown_y, MenuLib.selected_keys.bhop_indicator)
    
    -- Draw dropdown menus (right-aligned)
    for _, dropdown in ipairs(dropdowns_to_draw) do
        render.draw_rectangle(dropdown.x, dropdown.y + dropdown.height, dropdown.width, #MenuLib.key_options * 20, 30, 30, 30, 255, 0, true)
        
        for i, key in ipairs(MenuLib.key_options) do
            local item_y = dropdown.y + dropdown.height + (i-1) * 20
            local item_hovered = mouse_x >= dropdown.x and mouse_x <= dropdown.x + dropdown.width and 
                               mouse_y >= item_y and mouse_y <= item_y + 20
            
            render.draw_rectangle(dropdown.x, item_y, dropdown.width, 20, 
                                item_hovered and 70 or 30, 
                                item_hovered and 70 or 30, 
                                item_hovered and 70 or 30, 255, 0, true)
            
            render.draw_text(menu.font, key.name, dropdown.x + 5, item_y + 3, 255, 255, 255, 255, 0, 0, 0, 0, 0)
        end
    end
    
    -- Draw version number at the very bottom
    render.draw_text(menu.font, " " .. MenuLib.version, menu.x + menu.width - 30, menu.y + menu.height - 20, 150, 150, 150, 255, 0, 0, 0, 0, 0)
end

function MenuLib.create_checkbox(option_idx, x, y)
    local option = MenuLib.config.options[option_idx]
    local state, text = option[1], option[2]
    
    render.draw_rectangle(x, y, 15, 15, 200, 200, 200, 255, 0, true)
    
    if state then 
        render.draw_rectangle(x + 3, y + 3, 9, 9, MenuLib.colors.accent.r, MenuLib.colors.accent.g, MenuLib.colors.accent.b, 255, 0, true) 
    end
    
    render.draw_text(MenuLib.config.menu.font, text, x + 20, y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    
    if input.is_key_pressed(0x01) then
        local mouse_x, mouse_y = input.get_mouse_position()
        if mouse_x > x and mouse_x < x + 15 and mouse_y > y and mouse_y < y + 15 then 
            option[1] = not state 
        end
    end
end

MenuLib.initialize()
engine.register_on_engine_tick(function() MenuLib.render() end)
engine.log("MenuLib " .. MenuLib.version .. " loaded with all features enabled by default (Press END to toggle)", 0, 255, 255, 255)
return MenuLib