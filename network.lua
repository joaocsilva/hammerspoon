local network = {
  wifi = nil,
  int_ip = nil,
  ext_ip = nil,
  net = 0,
}

-- Return network status.
function networkLabel()
  return 'Network: ' .. network.net
end

-- Return external IP address.
function networkExternalIP()
  if hs.network.reachability.internet():status() == 0 then
    return '..'
  end
  if network.ext_ip and network.ext_ip ~= '' then
    return network.ext_ip
  end
  result = hs.execute('curl https://ipecho.net/plain')
  if result == nil then
    return '..'
  end
  network.ext_ip = result
  return result
end

-- Return internal IP address.
function networkInternalIP()
  if network.int_ip then
    return network.int_ip
  end
  local i = hs.network.primaryInterfaces()
  if not i then
    return '..'
  end
  d = hs.network.interfaceDetails(i)
  if not d.IPv4 then
    return '..'
  end
  network.int_ip = d.IPv4.Addresses[1]
  return network.int_ip
end

-- Return Wifi name.
function networkWifiName()
  if network.wifi then
    return network.wifi
  end
  result = hs.wifi.currentNetwork()
  if result == nil then
    return '..'
  end
  network.wifi = result
  return result
end


-- Set the network status.
function networkPingCallback(object, eventType, ...)
  if eventType == 'didFinish' then
    avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
    if avg == 0.0 then
      network.net = '0'
    elseif avg < 200.0 then
      network.net = 'Good (' .. avg .. 'ms)'
    elseif avg < 500.0 then
      network.net = 'Poor (' .. avg .. 'ms)'
    else
      network.net = 'Bad (' .. avg .. 'ms)'
    end
  end
end

-- Execute a ping request.
function networkPing()
  hs.network.ping('8.8.8.8', 3, 1.0, 2.0, 'any', networkPingCallback)
end

-- Watch Wifi connection, if changed reset the values so they are refreshed.
function networkWatcherCallback()
  if message == 'SSIDChange' then
    if not hs.wifi.currentNetwork() then
      network.wifi = nil
      network.net = 0
      network.int_ip = nil
      network.ext_ip = nil
    end
  end
end

hs.wifi.watcher.new(networkWatcherCallback):start()
print('-- Watcher started: Network')
