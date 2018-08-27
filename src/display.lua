
local sda, scl, sla = 1, 2, 0x3c
local font = u8g.font_chikita
local updateFifo = {}

local function updateDisplay(func)
  -- Desenha uma página e programa a escrita da próxima
  local function drawPages()
    func()
    if (disp:nextPage() == true) then
      node.task.post(drawPages)
    end
  end
  -- Restart the draw loop and start drawing pages
  disp:firstPage()
  node.task.post(drawPages)
end

function writeText(x, y, str)

end

function setup(sda, scl, sla, tmrID)
  i2c.setup(0, sda, scl, i2c.SLOW)
  disp = u8g.sh1106_128x64_i2c(sla
  --tmr.alarm(tmrID, 100, tmr.ALARM_AUTO, )
end
