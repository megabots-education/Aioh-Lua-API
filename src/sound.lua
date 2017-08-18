module("sound", package.seeall)

local timerID = 1
local t = {}
t["c"] = 261    -- do
t["d"] = 294    -- ré
t["e"] = 329    -- mi
t["f"] = 349    -- fá
t["g"] = 391    -- sol
t["gS"] = 415   -- sol bemol
t["a"] = 440    -- la
t["aS"] = 455   -- la bemol
t["b"] = 466    -- si
t["cH"] = 523   -- do sustenido
t["cSH"] = 554  -- do bemol
t["dH"] = 587   -- ré sustenido
t["dSH"] = 622  -- ré bemol
t["eH"] = 659   -- mi sustenido
t["fH"] = 698   -- fá sustenido
t["fSH"] = 740  -- fá bemol
t["gH"] = 784   -- sol sustenido
t["gSH"] = 830  -- sol bemol
t["aH"] = 880   -- la sustenido

-- Retorna a frequência de um determinado tom
function getFreq(tone)
  return t[tone]
end

-- Toca uma nota usando pwm de forma assíncrona, isto é, não trava o código do
-- programa enquanto toca.
function playNote(pin, tone, time, callback)
  local freq = getFreq(tone)

  pwm.setup(pin, freq, 512)
  pwm.start(pin)

  tmr.alarm(timerID, time, tmr.ALARM_SINGLE, function()
    pwm.stop(pin)
    tmr.wdclr()
    tmr.delay(20000)

    -- Se definiu um callback, invoca-o
    if callback ~= nil then
      callback()
    end
  end)
end

-- Toca uma nota usando pwm de forma síncrona, isto é, trava o código do
-- programa enquanto toca.
function sPlayNote(pin, tone, time)
  local freq = getFreq(tone)

  pwm.setup(pin, freq, 512)
  pwm.start(pin)

  tmr.delay(time * 1000)

  pwm.stop(pin)
  tmr.wdclr()
  tmr.delay(20000)
end

-- Toca uma música de forma assíncrona.
-- A música deve ser um vetor de vetores de duas posições.
-- Cada "linha" deverá conter o tom e o tempo em milissegundos de cada nota.
-- Exemplo:
--  music = {}
--  music[1] = {"a", 500}
--  music[2] = {"f", 350}
-- Utilize o tom "w" para definir um delay entre as notas.
function playMusic(pin, music, callback, actualNote)

  if actualNote == nil then
    actualNote = 1
  elseif actualNote > table.getn(music) then
    if callback ~= nil then
      callback()
    end
    return
  end

  if music[actualNote][1] == "w" then
    tmr.alarm(timerID, music[actualNote][2], tmr.ALARM_SINGLE, function()
      tmr.wdclr()
      playMusic(pin, music, callback, actualNote + 1)
    end)
    return
  end

  playNote(pin, music[actualNote][1], music[actualNote][2], function()
    playMusic(pin, music, callback, actualNote + 1)
  end)
end

-- Toca uma música de forma ssíncrona.
-- A música deve ser um vetor de vetores de duas posições.
-- Cada "linha" deverá conter o tom e o tempo em milissegundos de cada nota.
-- Exemplo:
--  music = {}
--  music[1] = {"a", 500}
--  music[2] = {"f", 350}
-- Utilize o tom "w" para definir um delay entre as notas.
function sPlayMusic(pin, music, note)

  if note == nil then
    note = 1
  end

  for note = note, table.getn(music), 1 do
    if music[note][1] == "w" then
      tmr.delay(music[note][2] * 1000)
    else
      sPlayNote(pin, music[note][1], music[note][2])
    end
  end
end
