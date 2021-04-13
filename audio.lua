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
        for _, device in pairs(config.audio.forceInputDevices) do
            if device.from == currentName and currentName ~= device.to then
                if hs.audiodevice.findInputByName(device.to):setDefaultInputDevice() then
                    log({ 'Audio: device changed: ' .. currentName .. ' -> ' .. device.to .. '.' })
                else
                    log({ 'Audio: fail to change: ' .. currentName .. ' -> ' .. device.to .. '.' })
                end
            end
        end
    end
end
-- Start the watcher if any config is provided.
if config.audio.forceInputDevices ~= '' or config.audio.forceInputDevices ~= nil then
    hs.audiodevice.watcher.setCallback(audioWatcherCallback)
    hs.audiodevice.watcher.start()
    log({ 'Watcher started: Force input device.' })
    audioWatcherCallback('dIn ')
end


-- Mute the volume when the computer wakes up.
function muteWatcherCallback(event)
    if (event == hs.caffeinate.watcher.systemDidWake) then
        local output = hs.audiodevice.defaultOutputDevice()
        output:setMuted(true)
        log({ 'Mute on awake: Device muted.' })
    end
end
-- Start the watcher if any config is provided.
if config.audio.muteOnAwake then
    caffeinateWatcher = hs.caffeinate.watcher.new(muteWatcherCallback):start()
    log({ 'Watcher started: Mute on awake.' })
end
