local obj = {}
obj.__index = obj
obj.__name = 'seal_dateconvert'
obj.icon = hs.image.imageFromName(hs.image.systemImageNames.TouchBarAlarmTemplate)

function obj:commands()
    return {}
end

function obj:bare()
    return self.bareCalc
end

function obj.bareCalc(query)
    local choices = {}
    if tostring(query):find('^%s*$') ~= nil then
        return choices
    end

    if tonumber(query) ~= nil then
        date = os.date('%Y-%m-%d %H:%M:%S', query)
        if date then
            local choice = {}
            choice['text'] = query .. ' = ' .. date
            choice['subText'] = 'Copy Date to clipboard'
            choice['image'] = obj.icon
            choice['plugin'] = obj.__name
            choice['type'] = 'copyToClipboard'
            table.insert(choices, choice)
        end
    elseif isValidDatetime(query) then
        local pattern = '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'
        local runyear, runmonth, runday, runhour, runminute, runseconds = query:match(pattern)
        local convertedTimestamp = os.time({ year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds })
        local choice = {}
        choice['text'] = query .. ' = ' .. convertedTimestamp
        choice['subText'] = 'Copy Time to clipboard'
        choice['image'] = obj.icon
        choice['plugin'] = obj.__name
        choice['type'] = 'copyToClipboard'
        table.insert(choices, choice)
    end

    return choices
end

function obj.completionCallback(rowInfo)
    if rowInfo['type'] == 'copyToClipboard' then
        hs.pasteboard.setContents(string.match(rowInfo['text'], " = (.*)"))
    end
end

-- Check if given string is a valid datetime.
function isValidDatetime(str)
    if str == '' or str == nil then
        return false
    end

    local y, m, d, hh, mm, ss = str:match('^(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)$')
    if not m or not d or not y or not hh or not mm or not ss then
        return false
    end
    y, m, d, hh, mm, ss = tonumber(y), tonumber(m), tonumber(d), tonumber(hh), tonumber(mm), tonumber(ss)

    if d < 0 or d > 31 or m < 0 or m > 12 or y < 0 or
            hh < 0 or hh > 24 or mm < 0 or mm > 60 or ss < 0 or ss > 60 then
        -- Cases that don't make sense
        return false
    elseif m == 4 or m == 6 or m == 9 or m == 11 then
        -- Apr, Jun, Sep, Nov can have at most 30 days
        return d <= 30
    elseif m == 2 then
        -- Feb
        if y % 400 == 0 or (y % 100 ~= 0 and y % 4 == 0) then
            -- if leap year, days can be at most 29
            return d <= 29
        else
            -- else 28 days is the max
            return d <= 28
        end
    else
        -- all other months can have at most 31 days
        return d <= 31
    end
end

return obj
