
local sensorState = { bme280 = false }

function sensorsInit ()
 local i2c_sda = 2
 local i2c_scl = 3
 if i2c_sda and i2c_scl then
  bme280.init ( i2c_sda, i2c_scl )
  sensorState.bme280 = true
 else
  print ( "ERROR: i2c_sda or i2c_sdl is not defined!" )
 end
end

function sensorsMeasure ()
 if sensorState and sensorState.bme280 and sensorState.bme280 == true then
  local T, P, H, QNH = bme280.read()
  local D = bme280.dewpoint(H, T)
  storage.temp  = T ~= nil and T or 0
  storage.press = P ~= nil and P or 0
  storage.humi  = H ~= nil and H or 0
  storage.dew   = D ~= nil and D or 0
 end
end

sensorsInit()
tmr.alarm ( 2, 1000, tmr.ALARM_AUTO, sensorsMeasure )