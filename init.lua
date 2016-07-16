--init.lua
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config("KzaDJ","password")
wifi.sta.connect()
tmr.alarm(1, 10000, 1, function() 
if wifi.sta.getip()== nil then 
print("IP unavaiable, Waiting....") 
else 
tmr.stop(1)
print("Config done, IP is "..wifi.sta.getip())
print("MAC is "..wifi.ap.getmac())
dofile("pega2Dh.lc") -- pegaDh11.lua
end 
end)


