module("httpsvr", package.seeall)

local defaultPort = 80
local serverPaths = {}

function stringSplit(self, delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

local function requestPreProcessor(payload)

  payload = stringSplit(payload, "\r\n\r\n")
  local tmpHeader = stringSplit(payload[1], "\r\n")
  tmpHeader[1] = stringSplit(tmpHeader[1], " ")

  local request = {}
  request.body = payload[2]
  request.method = tmpHeader[1][1]
  request.uri = tmpHeader[1][2]
  request.httpVer = tmpHeader[1][3]

  table.remove(tmpHeader, 1)

  request.header = {}
  for n, w in ipairs(tmpHeader) do
    headerAttr = stringSplit(w, ": ")
    request.header[headerAttr[1]] = headerAttr[2]
  end
  headerAttr = nil

  collectgarbage()
  return request
end

function sendResponseCode(conn, code)
  conn:send("HTTP/1.1 " .. code .. "\r\n\r\n")
end

function sendResponse(conn, code, message)
  sendResponseCode(conn, code)
  if message then
    conn:send(message)
  end
end

function attatchEvent(uri, method, func)
  if serverPaths[uri] == nil then
    serverPaths[uri] = {}
  end

  serverPaths[uri][method] = func
end

function start(port)
  if port == nil then
    port = defaultPort
  end

  srv=net.createServer(net.TCP)
  srv:listen(port,function(conn)

    conn:on("receive",function(conn,payload)

      request = requestPreProcessor(payload)

      if request.httpVer ~= "HTTP/1.1" then
        sendResponse(conn, 500, "HTTP version not supported")
      elseif serverPaths[request.uri] == nil then
        sendResponse(conn, 404, "Path not registered")
      elseif serverPaths[request.uri][request.method] == nil then
        sendResponse(conn, 405, "Method not allowed")
      else
        serverPaths[request.uri][request.method](conn, request)
      end
    end)

    conn:on("sent",function(conn)
        conn:close()
        collectgarbage()
    end)
  end)
end
