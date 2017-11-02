--[[
  telnetsrv: Telnet Server
  Implementação de um servidor telnet básico baseada no exemplo disponível no
  repositório oficial do firmware do NodeMCU
  (https://github.com/nodemcu/nodemcu-firmware).
]]--

module("telnetsrv", package.seeall)

local defaultPort = 23

function start(port)

  if port == nil then
    port = defaultPort
  end

  local telnetsrv = net.createServer(net.TCP, 180)

  telnetsrv:listen(port, function(socket)
    local fifo = {}
    local fifo_drained = true

    local function sender(c)
      if #fifo > 0 then
        c:send(table.remove(fifo, 1))
      else
        fifo_drained = true
      end
    end

    local function s_output(str)
      table.insert(fifo, str)
      if socket ~= nil and fifo_drained then
        fifo_drained = false
        sender(socket)
      end
    end

    -- define a saída padrão como sendo o callback s_output
    node.output(s_output, 1)

    socket:on("receive", function(c, l)
      -- ctrl+d para sair
      if l == string.char(255) .. string.char(236) then
        c:close()
        node.output(nil)
      else
        node.input(l)
      end
    end)
    socket:on("disconnection", function(c)
      -- restaura a saida padrão para a porta serial
      node.output(nil)
      collectgarbage()
    end)
    socket:on("sent", sender)

    print("Aioh Telnet Server.")
    print("Insira CTRL+D para encerrar a conexão.")
  end)
end
