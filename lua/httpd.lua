
require ( "ext_httpd" )

function setPinState(pin,value)
  local gpio=gpio
  gpio.mode(pin,gpio.OUTPUT)
  gpio.write(pin,value==1 and gpio.HIGH or gpio.LOW)
  return gpio.read(pin)
end

function getPinState(pin)
  local gpio=gpio
  return gpio.read(pin)
end

function switchPinState(pin)
  local gpio=gpio
  return setPinState(pin,gpio.read(pin)==1 and 0 or 1)
end

function saveToFile(_f,_c)
  local file,s=file,false
  if file.open(_f,"w")then
    file.write(_c)
    file.close()
    s=true
  end
  return s
end

serverOn ( "POST", "/api/wifi/set", function ( auth, dataType, data )
  local redirect = "/static/wifi.htm" 
  if data and data["ssid"] and data["password"] and data["mode"] then
    if data["mode"] == "AP" and saveToFile ( "ext_wifi_set.lua", 'wifiMode="AP"\n') == true then
      redirect = "/"
    end
    if data["mode"] == "STATION" and data["ssid"] ~= "" and saveToFile ( "ext_wifi_set.lua", 'wifiMode="STATION"\nwifiSSID="'..data["ssid"]..'"\nwifiPassword="'..(data["password"] or "")..'"\n') == true then
      redirect = "/"
    end
  end
  return 302, redirect
end)

local doorPin = 1
local doorState = setPinState ( doorPin, 0 )

serverOn ( "ALL", "/api/dash", function ( auth, dataType, data )
  local temp  = storage.temp and storage.temp / 100 or 0
  local humi  = storage.humi and storage.humi / 1000 or 0
  local dew   = storage.dew and storage.dew / 100 or 0
  local press = storage.dew and storage.press / 1000 or 0
  return "json", '{"#tempt":"'..temp..'","#tempv":{"_":"'..temp..'"},"#humit":"'..humi..'","#humiv":{"_":"'..humi..'"},"#dewt":"'..dew..'","#dewv":{"_":"'..dew..'"},"#presst":"'..press..'","#pressv":{"_":"'..press..'"}}'
end)

serverOn ( "POST", "/api/switch", function ( auth, dataType, data )
  if dataType == "form" and data and data.doorSw then
    doorState   = setPinState ( doorPin, ( data.doorSw == "true" and 1 or 0 ) )
    local switchState = doorState == 1 and "true" or "false"
    local doorMessage = doorState == 1 and "OPEN" or "CLOSE"
    return "json", '{"@doorSw":'..switchState..',"#doorMsg":"'..doorMessage..'"}'
  else
    return "json", '{}'
  end
end)




