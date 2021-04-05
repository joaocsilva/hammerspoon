local current = {
  direction = nil,
  count = 0,
}

function windowMove(direction)
  return function()
    local win      = hs.window.focusedWindow()
    local app      = win:application()
    local app_name = app:name()
    local f        = win:frame()
    local screen   = win:screen()
    local max      = screen:frame()

    -- Reset count if direction has changed.
    if current.direction ~= direction then
      current.count = 0
    end
    current.count = current.count + 1
    current.direction = direction

    -- If is the second time (or more) change the direction.
    if current.count > 1 then
      if current.direction == 'top' then current.direction = 'full'
      elseif current.direction == 'down' then current.direction = 'center'
      elseif current.direction == 'right' then current.direction = 'right_half'
      elseif current.direction == 'left' then current.direction = 'left_half'
      end
    end
    if current.direction == 'center' then
      f.x = (max.w / 4)
      f.y = (max.h / 4)
      f.w = (max.w / 2)
      f.h = (max.h / 2)
    elseif current.direction == 'left' then
      f.x = max.x
      f.y = max.y
      f.w = (max.w / 2)
      f.h = max.h
    elseif current.direction == 'left_half' then
      f.x = max.x
      f.y = (max.h / 3)
      f.w = (max.w / 2)
      f.h = (max.h / 2)
    elseif current.direction == 'right' then
      f.x = (max.x + (max.w / 2))
      f.y = max.y
      f.w = (max.w / 2)
      f.h = max.h
    elseif current.direction == 'right_half' then
      f.x = (max.x + (max.w / 2))
      f.y = (max.h / 3)
      f.w = (max.w / 2)
      f.h = (max.h / 2)
    elseif current.direction == 'top' then
      f.x = max.x
      f.y = max.y
      f.w = max.w
      f.h = (max.h / 2)
    elseif current.direction == 'down' then
      f.x = max.x
      f.y = (max.h / 2)
      f.w = max.w
      f.h = (max.h / 2)
    elseif current.direction == 'top_right' then
      f.x = max.x + (max.w / 2)
      f.y = max.y
      f.w = (max.w / 2) - 9
      f.h = (max.h / 2) - 12
    elseif current.direction == 'top_left' then
      f.x = max.x
      f.y = max.y
      f.w = (max.w / 2) - 9
      f.h = (max.h / 2) - 12
    elseif current.direction == 'down_left' then
      f.x = max.x
      f.y = (max.h / 2)
      f.w = (max.w / 2) - 9
      f.h = (max.h / 2) - 12
    elseif current.direction == 'down_right' then
      f.x = (max.w / 2)
      f.y = (max.h / 2)
      f.w = (max.w / 2) - 9
      f.h = (max.h / 2) - 12
    elseif current.direction == 'full' then
      f.x = max.x
      f.y = max.y
      f.w = max.w
      f.h = max.h
    end
    win:setFrame(f, 0.0)
  end
end
