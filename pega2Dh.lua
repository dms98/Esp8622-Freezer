-- Pega dados de 2 sensores
-- 2015 DMS

pin = 3
pin2 = 4
ehDebug = true
TempoRepetir = 300000 -- ms antes de Rodar a rotina principal.  5 minutos
Quantidade_Repetir = 12 -- Qnt antes d mandar 1 new ponto = 12x 300s = 1 hora
tempo_Repetir_email = 12 -- 12
AlarmeMaxTemp = -5 -- Temperatura para enviar e-mail.
ow.setup(pin)
ow.setup(pin2)

counter=0
lastTemp=-999
lastHumi=-999
temp=-999
humi=-999
temp2=-999
humi2=-999
menorTemp=1000
maiorTemp=-100
menorHumid=1000
maiorHumid=-100
status="-"
rodando = 0 -- qnt rodando.
mudouValor = false
lastMail = 0


function logD(mensagem)
  if (ehDebug == true) then
    print (mensagem);
  end
end

-- converte o valor booleano
function bol2string(valor)
  local st = ""
  if valor==nil then
   st="NULL"
  elseif valor==true then 
    st="TRUE" else st="FALSE" 
  end
  return st
end

--- Get temp de qualquer DHxx
function getTemp()
  status,temp,humi,temp_decimial,humi_decimial = dht.readxx(pin)
  if( status == dht.OK ) then
    -- Integer firmware using this example
    -- Float firmware using this example
    print("DHT ("..pin..") Temperature:"..temp.." / ".."Humidity:"..humi)
  elseif( status == dht.ERROR_CHECKSUM ) then
    print( "DHT Checksum error." );
  elseif( status == dht.ERROR_TIMEOUT ) then
    print( "DHT Time out." );
  end
  status,temp2,humi2,temp_decimial,humi_decimial = dht.read(pin2)
  --temp2=99
  --humi2=99
  if( status == dht.OK ) then
    print("DHT ("..pin2..") Temperature:"..temp2.." / ".."Humidity:"..humi2)
  end  
end


function roda()

  rodando = rodando + 1
  counter = counter + 1
   -- pega os dados de temperatura
   getTemp() 
   t1 = temp
   t2 = (temp >= 0 and temp % 10000) or (10000 - temp % 10000)
   logD("Temp:"..t1 .. "."..string.format("%04d", t2).." C\n")

   mudouValor = false
   -- pega os max e min
   if temp>maiorTemp then
    maiorTemp=temp
    mudouValor = true
  end
   if temp<menorTemp and temp>-100 then
    menorTemp=temp
    mudouValor = true
  end
  if humi>maiorHumid then
    maiorHumid=humi
    --mudouValor = true
  end
  if humi<menorHumid and humi>-100 then
    menorHumid=humi
    --mudouValor = true
  end

  -- confere mudanca de valor
  if temp~=lastTemp and temp>-100 then
    lastTemp=temp
    mudouValor = true
  end
  if humi~=lastHumi and temp>-100 then
    lastHumi=humi
    -- mudouValor = true
  end

  logD("Mudou o valor min/Max: " .. bol2string(mudouValor) .. "  --- Vezes rodando = " .. rodando .. "  -  Status: " .. status)
  logD("Menor Temp: " ..menorTemp.. " / Maior Temp: " .. maiorTemp .. " -- cnt=" .. counter)
  logD("Menor Humid: " ..menorHumid.. " / Humid Temp: " .. maiorHumid)

  -- verifica se ja rodou as vezes necessarias ou mudou o Valor
  if mudouValor or rodando>=Quantidade_Repetir then
    rodando = 0

    if temp>AlarmeMaxTemp then
      status=temp
      msg = "Temperatura%20de%20<B>" .. temp .. "%C2%B0C</B>%20atingida!<BR>" .. "Umidade:%20" .. humi .. "<BR>"
      msg = msg .. "Temperatura%20Min/Max:%20<B>" .. menorTemp .. "</B>%20/%20<B>" .. maiorTemp .. "</B><BR>" 
      msg = msg .. "Umidade%20Min/Max:%20<B>" .. menorHumid .. "</B>%20/%20<B>" .. maiorHumid .. "</B><BR>" 
      msg = msg .. "Counter:%20<B>" .. counter .. "</B><BR>"
      local vaiRepetir = lastMail + (tempo_Repetir_email*Quantidade_Repetir) -- (lastMail+tempo_Repetir_email)
      logD("-- Counter / vaiRepetir: " .. counter .. " / " .. vaiRepetir)
      if lastMail==0 or counter >= vaiRepetir then
        lastMail = counter
        sendMail(msg)
      end
    end
    -- envia os dados
    sendData()
  end
end

function sendData()
 
  -- conection to thingspeak.com
  logD("Sending data to thingspeak.com")
  urlGET = "GET /update?key=thingspeekCode&field1="..temp.."&field2="..humi.."&field3="..temp2.."&field4="..humi2.."&field5="..counter.." HTTP/1.1\r\n"
  logD(urlGET)
 
  conn=net.createConnection(net.TCP, 0) 
  conn:on("receive", function(conn, payload) print(payload) end)
  -- api.thingspeak.com 184.106.153.149
  conn:connect(80,'184.106.153.149') 
  conn:send(urlGET) 
  conn:send("Host: api.thingspeak.com\r\n") 
  conn:send("Accept: */*\r\n") 
  conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
  conn:send("\r\n")
  conn:on("sent",function(conn)
                        print("Closing connection")
                        conn:close()
                    end)
  conn:on("disconnection", function(conn)
                                  print("Got disconnection...")
    end)
end

function sendMail(msg)
 
  --http://sebrae.esy.es/Dmail.php?message=teste&envia=nao&par_op=altaTemperatura
  
  logD("Sending e-mail to d-Mail")
  --msg="msg - TEste"
  logD("MSG: " .. msg)
  urlGET = "GET /Dmail.php?envia=Sim&par_op=altaTemperatura&message="..msg.." HTTP/1.1\r\n"
  logD("urlGET:" .. urlGET)
 
  conn=net.createConnection(net.TCP, 0) 
  conn:on("receive", function(conn, payload) print(payload) end)
  -- sebrae.esy.es/Dmail.php
  conn:connect(80,'31.220.16.221') -- 31.220.16.229
  conn:send(urlGET) 
  conn:send("Host: sebrae.esy.es\r\n") 
  conn:send("Accept: */*\r\n") 
  conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
  conn:send("\r\n")
  conn:on("sent",function(conn)
                        print("Closing connection")
                        conn:close()
                    end)
  conn:on("disconnection", function(conn)
                                  print("Got disconnection...")
    end)
end


--- inicio do APP
--- informacoes de inicio
print ("eh Debug: " .. bol2string(ehDebug));
print ("Tempo Repetir: " .. TempoRepetir .. "ms");
print ("Quantidade_Repetir: " .. Quantidade_Repetir .. " vezes.");
print ("Alarme Temperatura Maxima: " .. AlarmeMaxTemp .. " C."); 
print ("Pino DH22: " .. pin); 
print ("Tempo Repetir email: " .. tempo_Repetir_email .. " vezes"); 


-- send data every X ms to thing speak
tmr.alarm(0, TempoRepetir, 1, function() roda() end )
