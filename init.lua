-- Load Spoons.
hs.loadSpoon('Seal')
hs.loadSpoon('HoldToQuit')

-- Load custom plugins.
require('config')
require('reload')
require('window')
require('battery')
require('network')
require('caffeine')
require('audio')

-- Bind Reload configs.
hs.hotkey.bind(config.hyper, 'R', reloadWatcherCallback)

-- HoldToQuit configuration.
spoon.HoldToQuit.duration = config.HoldToQuit.duration
spoon.HoldToQuit:init()
spoon.HoldToQuit:start()


-- Seal configuration.
spoon.Seal:bindHotkeys({show = config.Seal.hotkey})
spoon.Seal:loadPlugins({
  'apps',
  'pasteboard',
  'calc',
  'screencapture',
  'useractions',
  'dateconvert',
  'gtranslate',
})
spoon.Seal.chooser:width(45)
spoon.Seal.chooser:placeholderText(config.Seal.placeholder)
spoon.Seal.chooser:searchSubText(true)
spoon.Seal.plugins.useractions.actions = config.Seal.useractions
spoon.Seal.plugins.screencapture.showPostUI = true
spoon.Seal.plugins.gtranslate.key = config.Seal.key
spoon.Seal:refreshAllCommands()
spoon.Seal:start()


-- Window movement.
hs.hotkey.bind(config.hyper, 'Left', windowMove('left'))
hs.hotkey.bind(config.hyper, 'Right', windowMove('right'))
hs.hotkey.bind(config.hyper, 'Up', windowMove('top'))
hs.hotkey.bind(config.hyper, 'Down', windowMove('down'))


-- Bind applications hotkeys.
for key, app in pairs(config.applications) do
  hs.hotkey.bind(config.hyper, key, function() hs.application.launchOrFocus(app) end)
end


-- Return a string containing the connected screens.
function getScreens()
  local screens = {}
  hs.fnutils.each(hs.screen.allScreens(), function (item)
    table.insert(screens, item:name())
  end)
  return 'Screens: ' .. table.concat(screens, ', ')
end


--[[
By calling here the ping, there's a bigger chance to have it
done when the menu is opened for the first time.
]]--
networkPing()

-- Create the menu.
local menu = hs.menubar.new()
:setTitle(config.menu.icon)
:setMenu(function()
  wifi = networkWifiName()
  int_ip = networkInternalIP()
  ext_ip = networkExternalIP()

  caffeine_timers = {{title = 'Indefinitely', fn = caffeineTimerNew(0)}}
  if config.menu.caffeine then
    for _, item in pairs(config.menu.caffeine) do
      table.insert(caffeine_timers, {
        title = item.title,
        fn = caffeineTimerNew(item.seconds),
      })
    end
  end

  local menu = {
    {title = 'Wifi: ' .. wifi, fn = function() hs.pasteboard.setContents(wifi) end},
    {title = networkLabel(), fn = networkPing},
    {title = 'Internal IP: ' .. int_ip, fn = function() hs.pasteboard.setContents(int_ip) end},
    {title = 'External IP: ' .. ext_ip, fn = function() hs.pasteboard.setContents(ext_ip) end},
    {title = '-'},
    {
      title = 'Stay awake for',
      checked = caffeineChecked(),
      fn = caffeineToggle,
      menu = caffeine_timers,
    },
    {title = '-'},
    {title = getScreens()},
  }

  if config.menu.extended == true then
    table.insert(menu, {title = '-'})
    table.insert(menu, {title = 'hyper: ' .. table.concat(config.hyper, ' + '), disabled = true})

    if config.applications then
      for key, app in pairs(config.applications) do
        table.insert(menu, {title = app .. ': hyper + ' .. key})
      end
      table.insert(menu, {title = '-'})
    end

    table.insert(menu, {
      title = 'Window manager',
      menu = {
        {title = 'Left: hyper + ←', fn = windowMove('left')},
        {title = 'Left half: hyper + ← + ←', fn = windowMove('left_half')},
        {title = 'Right: hyper + →', fn = windowMove('right')},
        {title = 'Right half: hyper + → + →', fn = windowMove('right_half')},
        {title = 'Top: hyper + ↑', fn = windowMove('top')},
        {title = 'Maximize: hyper + ↑ + ↑', fn = windowMove('full')},
        {title = 'Down: hyper + ↓', fn = windowMove('down')},
        {title = 'Center: hyper + ↓ + ↓', fn = windowMove('center')},
        {title = 'Top Right', fn = windowMove('top_right')},
        {title = 'Top Left', fn = windowMove('top_left')},
        {title = 'DownRight', fn = windowMove('down_right')},
        {title = 'DownLeft', fn = windowMove('down_left')},
      }
    })
  end
  return menu
end)
