-- Force given input device to be always used.
function audioWatcherCallback(state)
    --[[
    'dIn ' - Default audio input device setting changed
    'dOut' - Default audio output device setting changed
    'sOut' - Default system audio output setting changed
    'dev#' - An audio device appeared or disappeared
    ]]--
    if state == 'dIn ' then
        local currentName = hs.audiodevice.defaultInputDevice():name()
        if currentName ~= config.audio.forceInputDevice then
            if hs.audiodevice.findInputByName(config.audio.forceInputDevice):setDefaultInputDevice() then
                print('-- Force input device: '.. currentName ..' -> ' .. config.audio.forceInputDevice)
            end
        end
    end
end
if config.audio.forceInputDevice ~= '' then
    hs.audiodevice.watcher.setCallback(audioWatcherCallback)
    hs.audiodevice.watcher.start()
    print('-- Watcher started: Force input device')
    audioWatcherCallback('dIn ')
end


-- Mute the volume when the computer wakes up.
function muteWatcherCallback(event)
    if (event == hs.caffeinate.watcher.systemDidWake) then
        local output = hs.audiodevice.defaultOutputDevice()
        print('-- Mute on awake: Device muted')
        output:setMuted(true)
    end
end
if config.audio.muteOnAwake then
    hs.caffeinate.watcher.new(muteWatcherCallback):start()
    print('-- Watcher started: Mute on awake')
end
