-- init.lua --

storage={}

tmr.alarm ( 0, 1000, tmr.ALARM_SINGLE, function ()

  require ( "sensors" )
  require ( "ext_wifi" )
  wifiInit()
  dofile ( "httpd.lua" )

end)


