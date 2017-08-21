--[[
  rmtprog: Remote Programming Module
  Esta parte da API é responsável por implementar o sistema de programação
  remota da plataforma. Por meio dela é possível enviar e obter arquivos
  gravados no Aioh e executar códigos Lua enviados via HTTP.
]]--

module("rmtprog", package.seeall)

require("httpsrv")

local function wifiConect(wifi_sta_config)
  wifi.setmode(wifi.STATION)
  wifi.sta.config(wifi_sta_config)
  wifi.sta.connect()

  local timeout = 0

  tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
      print("Conectando...")
      timeout = timeout + 1
    elseif timeout >= 60 then
      print("Não foi possível se conectar a rede wifi " .. wifi_sta_config.ssid .. "com a senha " .. wifi_sta_config.pwd)
    else
      tmr.stop(1)
      tmr.wdclr()
      timeout = nil
      print("Conectado com sucesso a rede " .. wifi_sta_config.ssid)
      ip, nm, gt = wifi.sta.getip()
      print("IP: " .. ip)
      print("MAC: " .. wifi.sta.getmac())
      print("Net Mask: " .. nm)
      print("Gateway: " .. gt)
    end
  end)
end

local function createFile(conn, req)
  if request.header["action"] == "create-file" then
    fd = file.open(request.header["file-name"], "w")
    if fd then
      fd:write(request.body)
      fd:close()
      httpsrv.sendResponse(conn, 200, "Arquivo criado com sucesso!")
    else
      httpsrv.sendResponse(conn, 500, "Erro ao criar arquivo")
    end
  else
    httpsrv.sendResponse(conn, 400, "Cabeçalho incompleto")
  end
end

local function loadFile(conn, req)
  if request.header["file-name"] then
    fd = file.open(request.header["file-name"], "r")
    httpsrv.sendResponseCode(conn, 200)
    line = fd:readline()
    repeat
        conn:send(line)
        line = fd:readline()
    until line == nil
    fd:close()
  else
    httpsrv.sendResponse(conn, 400, "Cabeçalho incompleto")
  end
end

local function deleteFile(conn, req)
  if request.header["file-name"] then
    file.remove(request.header["file-name"])
    httpsrv.sendResponse(conn, 200, "Arquivo apagado com sucesso!")
  else
      httpsrv.sendResponse(conn, 400, "Cabeçalho incompleto")
  end
end

local function runCode(conn, req)
  if request.body ~= nil then
    func = loadstring(request.body)
    func()
  else
    httpsrv.sendResponse(conn, 400, "Código não enviado")
  end
end

function start(wifi_sta_config, srvPort)

  if wifi_sta_config ~= nil then
    wifiConect(wifi_sta_config)
  end

  httpsrv.start(srvPort)

  httpsrv.attatchEvent("/", "GET", function(conn, request)
    loadFile(conn, req)
  end)

  httpsrv.attatchEvent("/", "POST", function(conn, req)
    createFile(conn, req)
  end)

  httpsrv.attatchEvent("/", "PUT", function(conn, req)
    runCode(conn, req)
  end)

  httpsrv.attatchEvent("/", "DELETE", function(conn, req)
    deleteFile(conn, req)
  end)
end
