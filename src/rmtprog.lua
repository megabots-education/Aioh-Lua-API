--[[
  rmtprog: Remote Programming Module
  Esta parte da API é responsável por implementar o sistema de programação
  remota da plataforma. Por meio dela é possível enviar e obter arquivos
  gravados no Aioh e executar códigos Lua enviados via HTTP.
]]--

module("rmtprog", package.seeall)

require("httpsrv")
require("log")

local log = log.start("RMTPROG")

local function wifiConect(wifi_sta_config)
  wifi.setmode(wifi.STATION)
  wifi.sta.config(wifi_sta_config)
  wifi.sta.connect()

  local timeout = 0

  tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
      log.log("Conectando a rede Wifi ...")
      timeout = timeout + 1
    elseif timeout >= 60 then
      log.log("Nao foi possível se conectar a rede wifi " .. wifi_sta_config.ssid .. "com a senha " .. wifi_sta_config.pwd)
    else
      tmr.stop(1)
      tmr.wdclr()
      timeout = nil
      log.log("Conectado com sucesso a rede " .. wifi_sta_config.ssid)
      ip, nm, gt = wifi.sta.getip()
      log.log("\tIP: " .. ip)
      log.log("\tMAC: " .. wifi.sta.getmac())
      log.log("\tNet Mask: " .. nm)
      log.log("\tGateway: " .. gt)

      log.log("Registrando servico Aioh")
      mdns.register("aiohdevice", {
        description="Aioh",
        service="http",
        port=80
      })
      log.log("Registrado")
    end
  end)
end

local function createFile(conn, req)
  log.pushPrefix("Create File")
  log.log("Solicitacao para criacao de arquivo recebida")
  if req.header["action"] == "create-file" then
    log.log("Criando arquivo: " .. req.header["file-name"])
    fd = file.open(req.header["file-name"], "w")
    if fd then
      fd:write(req.body)
      fd:close()

      httpsrv.sendResponse(conn, 200, "Arquivo criado com sucesso!")
      log.log("Arquivo criado com sucesso!")
      log.log("Conteudo do arquivo:\n" .. req.body)
      log.log("Fim do conteudo")
    else
      httpsrv.sendResponse(conn, 500, "Erro ao criar arquivo")
      log.log("Erro ao criar arquivo")
    end
  else
    httpsrv.sendResponse(conn, 400, "Cabecalho incompleto")
    log.log("Cabecalho incompleto recebido")
  end
  log.popPrefix()
end

local function loadFile(conn, req)
  log.pushPrefix("Run Code")
  log.log("Solicitacao para envio de arquivo recebida")
  if req.header["file-name"] then
    log.log("Abrindo arquivo \"" .. req.header["file-name"] .. "\"")
    fd = file.open(req.header["file-name"], "r")
    httpsrv.sendResponseCode(conn, 200)
    line = fd:readline()
    repeat
        conn:send(line)
        line = fd:readline()
    until line == nil
    fd:close()
    log.log("Arquivo carregado com sucesso!")
  else
    httpsrv.sendResponse(conn, 400, "Cabecalho incompleto")
    log.log("Cabecalho incompleto recebido")
  end
  log.popPrefix()
end

local function deleteFile(conn, req)
  log.pushPrefix("Delete File")
  log.log("Solicitacao para exclusao de arquivo recebida")
  if req.header["file-name"] then
    file.remove(req.header["file-name"])
    httpsrv.sendResponse(conn, 200, "Arquivo apagado com sucesso!")
    log.log("Arquivo apagado com sucesso!")
  else
      httpsrv.sendResponse(conn, 400, "Cabecalho incompleto")
      log.log("Cabecalho incompleto recebido")
  end
  log.popPrefix()
end

local function runCode(conn, req)
  log.pushPrefix("Run Code")
  log.log("Solicitacao para execucao de código")
  if req.body ~= nil then
    func = loadstring(req.body)
    func()
    log.log("Código está/foi executando(ado)!")
  else
    httpsrv.sendResponse(conn, 400, "Código nao enviado")
    log.log("Cabecalho incompleto recebido")
  end
  log.popPrefix()
end

function start(wifi_sta_config, srvPort, callback)

  if wifi_sta_config ~= nil then
    wifiConect(wifi_sta_config)
  else
    log.log("Informacões da rede Wifi nao foram informadas")
    if wifi.sta.getip() == nil then
      log.log("Rede Wifi nao está conectada. Nao é possível utilizar o sistema de programacao remota")
    end
  end

  log.log("Iniciando Servidor HTTP")
  httpsrv.start(srvPort)

  log.log("Registrando EndPoints")
  httpsrv.attatchEvent("/", "GET", function(conn, req)
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

  log.log("Sistema de programacao remota iniciado e configurado com sucesso!")

  if callback ~= nil then
    callback()
  end
end
