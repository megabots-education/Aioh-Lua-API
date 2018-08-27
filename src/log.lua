--[[
  log
  Esta parte da API é responsável por implementar o sistema de logs.
  Ela simplifica a exibição de logs do sistema.
]]--

module("log", package.seeall)

require("utils")

local logObj = {}
logObj.prefix = {}

function logNoPrefix(message)
  print(message)
end

function log(message)
  --TODO: Encontrar forma de não imprimir \n ao usar a função print ou similares.
  local prefix = tmr.now() .. " "
  for index,value in ipairs(#self.prefix) do
    prefix = prefix .. value .. " - "
  end
  print(prefix .. message)
end

function popPrefix()
  table.remove(logPrefix, table.getn(logPrefix))
end

function pushPrefix(prefix)
  table.insert(logPrefix, table.getn(logPrefix) + 1, prefix)
end

logObj.log = log
logObj.popPrefix = popPrefix
logObj.pushPrefix = pushPrefix
logObj.logNoPrefix = logNoPrefix

function start(prefix)
  newLog = utils.table.clone(logObj)
  if prefix ~= nil then
    table.insert(newLog.prefix, 1, prefix)
  end
  return newLog
end
