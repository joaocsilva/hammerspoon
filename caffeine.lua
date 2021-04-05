local caffeine = {
  checked = hs.caffeinate.get('displayIdle'),
  timer = nil,
}

-- Toggle the caffeinate state.
function caffeineToggle()
  if hs.caffeinate.toggle('displayIdle') then
    hs.alert.show('Caffeine is now active.')
    caffeine.checked = 1
  else
    hs.alert.show('Caffeine disabled.')
    caffeine.checked = 0
  end
end

-- Return checked state.
function caffeineChecked()
  return caffeine.checked == 1 and true or false
end

-- Check remaining timer time.
function caffeineTimerTime()
  if caffeine.checked == 1 and caffeine.timer then
    local number = math.floor(tonumber(caffeine.timer:nextTrigger()))
    if number < 1 then
      number = 0
    end
    return number .. ' sec.'
  else
    return 'off'
  end
end

-- Stop the timer.
function caffeineTimerStop()
  caffeine.checked = 0
  hs.caffeinate.set('displayIdle', false, true)
  caffeine.timer:stop()
end

-- Start the timer to finish in given seconds.
function caffeineTimerNew(interval)
  return function ()
    if caffeine.checked == 1 and caffeine.timer then
      caffeine.timer:stop()
    end
    caffeine.checked = 1
    hs.caffeinate.set('displayIdle', true, true)
    hs.alert.show('Caffeine is now active.')
    if interval > 0 then
      caffeine.timer = hs.timer.doAfter(interval, function ()
        hs.alert.show('Caffeine disabled.')
        caffeineTimerStop()
      end)
    end
  end
end
