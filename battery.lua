--[[
Watch for battery: alert if connected charger is not
the original or if the battery condition is not Good.
]]--
function batteryWatcherCallback()
    -- Check if the Serial is the original.
    if config.battery.serial ~= '' and hs.battery.powerSource() == 'AC Power' then
        local serial = hs.battery.psuSerialString()
        if serial ~= '' and serial ~= config.battery.serial then
            hs.alert.show("That's not your power supply! " .. tostring(serial))
        end
    end
    -- Alert in case the condition is not Good.
    if config.battery.state == true and hs.battery.health() ~= 'Good' then
        hs.alert.show('The Battery condition is ' .. hs.battery.health())
    end
end

-- Start the watcher if any config is provided.
if config.battery.state == true or config.battery.serial ~= '' then
    batteryWatcher = hs.battery.watcher.new(batteryWatcherCallback):start()
    log({ 'Watcher started: Battery.' })
    batteryWatcherCallback()
end
