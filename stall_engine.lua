local app_folder = ac.getFolder(ac.FolderID.ACApps) .. '/lua/stall_engine/'
function getFilePath(path)
    return app_folder .. path
end

local manifest = ac.INIConfig.load(getFilePath('manifest.ini'), ac.INIFormat.Extended)
local app_version = manifest:get('ABOUT','VERSION',0.1)

local starter_sound1 = ui.MediaPlayer()
starter_sound1:setSource(getFilePath('Starter1.mp3'))
starter_sound1:setLooping(false)
starter_sound1:setVolume(0.5) -- Set the volume

local starter_sound2 = ui.MediaPlayer()
starter_sound2:setSource(getFilePath('Starter2.mp3'))
starter_sound2:setLooping(true)
starter_sound2:setVolume(0.5) -- Set the volume

local starter_sound3 = ui.MediaPlayer()
starter_sound3:setSource(getFilePath('Starter3.mp3'))
starter_sound3:setLooping(false)
starter_sound3:setVolume(0.5) -- Set the volume

local ignition_sound = ui.MediaPlayer()
ignition_sound:setSource(getFilePath('Ignition.mp3'))
ignition_sound:setLooping(false)
ignition_sound:setVolume(0.1) -- Set the volume

local turn_off_sound = ui.MediaPlayer()
turn_off_sound:setSource(getFilePath('Kill.mp3'))
turn_off_sound:setLooping(false)
turn_off_sound:setVolume(1) -- Set the volume

local stall_sound = ui.MediaPlayer()
stall_sound:setSource(getFilePath('Stall.mp3'))
stall_sound:setLooping(false)
stall_sound:setVolume(0.3) -- Set the volume

local function playSound(sound)
    if SoundsEnabled then
        sound:play()
    end
end

local function get_config()
    Config = ac.INIConfig.load(getFilePath('config.ini'), ac.INIFormat.Extended)
    Enabled = Config:get('STALL', 'ENABLED', 'true') == 'true'
    StallRpm = Config:get('STALL', 'STALL_RPM', 1000)
    ClutchBitePoint = Config:get('STALL', 'CLUTCH_BITE_POINT', 0.5)
    IgnitionEnabled = Config:get('STALL', 'IGNITION_ENABLED', 'true') == 'true'
    SoundsEnabled = Config:get('STALL', 'SOUNDS_ENABLED', 'true') == 'true'
end

local function set_config(key, value)
    Config:set('STALL', key, value)
    Config:save(getFilePath('config.ini'))
    print("Config updated: " .. key .. " = " .. value)
end

local function ignitionEnabledChangedHandler(value)
    if value and (not Ignition_btn or not Ignition_btn:configured()) then
        print("Warning: Ignition button is not configured. Please set it in the controls menu.")
        ac.setMessage("stall_engine: Ignition button (Extra D) is not configured. Disabling ignition!", "", nil, 3)
        return false
    else
        return true
    end
end

local function EnabledChangedHandler(value)
    if value and (not Start_btn or not Start_btn:configured()) then
        print("Warning: Start button is not configured. Please set it in the controls menu.")
        ac.setMessage("stall_engine: Start button (Extra E) is not configured. Disabling stall_engine!", "", nil, 3)
        return false
    else
        return true
    end
end

local AlreadySetup = false
function script.onWindowShow()
    print("Stall Engine app window shown.")
    get_config()

    if AlreadySetup then
        return
    end

    StallRpm_input = StallRpm
    CBP_input = ClutchBitePoint
    Enabled_input = Enabled
    IgnitionOn = false
    EngineOn = false
    MaxRpm = ac.getCar().rpmLimiter or 8000
    MinRpm = ac.getCar().rpmMinimum or 900
    TurnOnDelayTimer = 0
    
    print("Current Config:")
    print("Enabled: " .. tostring(Enabled))
    print("Ignition Enabled: " .. tostring(IgnitionEnabled))
    print("Sounds Enabled: " .. tostring(SoundsEnabled))
    print("Max RPM: " .. MaxRpm)
    print("Min RPM: " .. MinRpm)
    print("Stall RPM: " .. StallRpm)
    print("Clutch Bite Point: " .. (ClutchBitePoint * 100) .. "%")
    
    Ignition_btn = ac.ControlButton('__EXT_LIGHT_D', nil)
    Start_btn = ac.ControlButton('__EXT_LIGHT_E', nil)

    if not EnabledChangedHandler(Enabled) then
        Enabled = false
        set_config('ENABLED', 'false')
    end
    
    if IgnitionEnabled then
        if not ignitionEnabledChangedHandler(IgnitionEnabled) then
            IgnitionEnabled = false
            set_config('IGNITION_ENABLED', 'false')
        else
            Ignition_btn:onPressed(function()
                if not IgnitionEnabled then
                    print("Warning: Ignition is not enabled.")
                    ac.setMessage("stall_engine: Ignition is not enabled.", "", nil, 1)
                    return
                end
                IgnitionOn = not IgnitionOn
                print("Ignition is set to " .. (IgnitionOn and "ON" or "OFF"))
                if IgnitionOn then
                    playSound(ignition_sound)
                end
            end)
        end
    end
    
    AlreadySetup = true
end

function script.windowMain(dt)
    ac.setWindowBackground('windowMain', rgbm(0.6, 0.6, 0.6, 0.5), true)

    Enabled_input = Enabled
    if ui.checkbox("Enable Stall", Enabled_input) then
        Enabled_input = not Enabled_input
        if Enabled_input ~= Enabled then
            Enabled = Enabled_input
            if not EnabledChangedHandler(Enabled) then
                Enabled = false
            else
                set_config('ENABLED', tostring(Enabled))
                ac.setMessage("stall_engine: " .. (Enabled and "Enabled" or "Disabled"), "", nil, 1)
            end
        end
    end

    if ui.checkbox("Ignition Required", IgnitionEnabled) then
        IgnitionEnabled = not IgnitionEnabled
        if not ignitionEnabledChangedHandler(IgnitionEnabled) then
            IgnitionEnabled = false
        end
        set_config('IGNITION_ENABLED', tostring(IgnitionEnabled))
    end

    if ui.checkbox("Sounds Enabled", SoundsEnabled) then
        SoundsEnabled = not SoundsEnabled
        set_config('SOUNDS_ENABLED', tostring(SoundsEnabled))
    end
    
    local changed
    StallRpm_input = StallRpm
    StallRpm_input, changed = ui.slider("##STALL RPM", StallRpm_input, 0, MaxRpm, "STALL RPM: %.0f")
    if changed then
        if StallRpm_input < 200 then
            StallRpm_input = MinRpm
        elseif StallRpm_input > MaxRpm then
            StallRpm_input = MaxRpm
        end

        StallRpm = StallRpm_input
        set_config('STALL_RPM', StallRpm)
    end

    if not ClutchBitePoint then
        ClutchBitePoint = 0.5 -- Default value if not set
    end
    CBP_input = ClutchBitePoint * 100
    CBP_input, changed = ui.slider("##CLUTCH BITE POINT", CBP_input, 0, 100, "CLUTCH BITE POINT: %.0f%%")
    if changed then
        if CBP_input < 0 then
            CBP_input = 0
        elseif CBP_input > 100 then
            CBP_input = 100
        end

        ClutchBitePoint = CBP_input / 100.0
        set_config('CLUTCH_BITE_POINT', ClutchBitePoint)
    end
end

function script.windowSettings(dt)
  -- draw settings ui
end

function script.update(dt)
    if not Enabled then
        return
    end

    local data = ac.getCarPhysics()
    if (not data) or data == nil then
        ac.console("Failed to access car physics data.")
        return
    end

    
    local gas = ac.getCar().gas or 0.0
    local brake = ac.getCar().brake or 0.0
    local rpm = ac.getCar().rpm or 0.0
    local gear = ac.getCar().gear or 0.0
    local clutch = ac.getCar().clutch or 1.0

    if clutch > ClutchBitePoint and rpm < StallRpm and (gear > 0 or gear == -1) then
        if not IsStalling and EngineOn then
            EngineOn = false
            print("Engine stopped due to stall.")
            playSound(stall_sound)
        end 
        IsStalling = true
    else
        IsStalling = false
    end
    
    if not EngineOn then
        local trying_to_start = (not IgnitionEnabled or IgnitionOn) and Start_btn:down()
        -- print(Start_btn:down())
        if trying_to_start and not TurnOnProtection then
            if not IsStalling then
                print(TurnOnDelayTimer)
                if TurnOnDelayTimer < 0.357 * 4 then
                    TurnOnDelay = true
                    print("Waiting for engine to start...")
                    if not starter_sound2:playing() then
                        playSound(starter_sound1)
                        starter_sound2:setCurrentTime(0)
                        starter_sound2:setLooping(true)
                        playSound(starter_sound2)
                    end
                    TurnOnDelayTimer = TurnOnDelayTimer + dt
                elseif TurnOnDelay then
                    starter_sound2:pause()
                    playSound(starter_sound3)
                    TurnOnDelayTimer = 0
                    TurnOnDelay = false
                    EngineOn = true
                    print("Engine started.")
                end
                return
            else
                if clutch < ClutchBitePoint then
                    print("Starter is trying to start the engine")
                    playSound(starter_sound2)
                    return
                end
            end
        end
        -- print("setting to 0")
        starter_sound2:setCurrentTime(0):pause()
        TurnOnDelayTimer = 0
        physics.setEngineRPM(0)
        if not TurnOnProtection then
            TurnOnProtectionTimer = 0
        end
        if TurnOnProtectionTimer > 1 then
            TurnOnProtection = false
        else
            TurnOnProtectionTimer = TurnOnProtectionTimer + dt
        end
        return
        
    end

    if EngineOn then
        if (IgnitionEnabled and not IgnitionOn) or Start_btn:pressed() then
            EngineOn = false
            print("Engine stopped.")
            TurnOnProtection = true
            TurnOnProtectionTimer = 0
            playSound(turn_off_sound)
            return
        end
    end
end
