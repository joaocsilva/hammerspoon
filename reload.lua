--[[
Replacement for ReloadConfiguration since it will listen for
changes in files that are not suppose to be watched.
This will act only on changes in .lua files.
]]--
function reloadWatcherCallback(files)
    reload = false
    -- Variable `files` is nil if called from hotkey.
    if files == nil then
        files = {}
        reload = true
    end
    for _, file in pairs(files) do
        if file:sub(-4) == '.lua' then
            reload = true
        end
    end
    if reload then
        hs.reload()
    end
end

if config.reload then
    pathWatcher = hs.pathwatcher.new(hs.configdir, reloadWatcherCallback):start()
    log({ 'Watcher started: Reload.' })
end
