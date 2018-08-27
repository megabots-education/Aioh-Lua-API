require "sound"

colors = {}
colors[1] = "red"
colors[2] = "blue"
colors[3] = "green"
colors[4] = "yellow"

buttons = {}
buttons["red"] = 4
buttons["blue"] = 6
buttons["green"] = 5
buttons["yellow"] = 7

leds = {}
leds["red"] = 0
leds["blue"] = 2
leds["green"] = 1
leds["yellow"] = 3

sound_pin = 8

notes = {}
notes["red"]  = "c" -- dó
notes["blue"]  = "d" -- ré
notes["green"]  = "e" -- mi
notes["yellow"]  = "f" -- fá

--[[
  Atributos iniciais do jogo
  Velocity é o tempo que a luz fica acesa e o som é Tocando
  Interval é o tempo entre cada uma das cores e sons
  Sequency é a quantidade de cores que são apresentadas
]]--
attributes = {}
attributes["velocity"] = 1000
attributes["interval"] = 200
attributes["sequency"] = 1
attributes["isSaying"] = false
attributes["isVerifying"] = false
attributes["level"] = 1
attributes["actualColors"] = {}
attributes["actualResponse"] = {}

--[[
  Multiplicadores do jogo
]]--
multipliers = {}
multipliers["velocity"] = 3/4
multipliers["interval"] = 3/4
multipliers["sequency"] = 1.5

print(" -> Multipliers:")
print("  - Velocity: " .. multipliers["velocity"])
print("  - Interval: " .. multipliers["interval"])
print("  - Sequency: " .. multipliers["sequency"])

--[[
    Inicializa os pinos
]]--
print(" -> Inicializando Pinos")
gpio.mode(buttons["red"], gpio.INT, gpio.PULLUP)
gpio.mode(buttons["blue"], gpio.INT, gpio.PULLUP)
gpio.mode(buttons["green"], gpio.INT, gpio.PULLUP)
gpio.mode(buttons["yellow"], gpio.INT, gpio.PULLUP)

--gpio.mode(buttons["red"], gpio.INT)
--gpio.mode(buttons["blue"], gpio.INT)
--gpio.mode(buttons["green"], gpio.INT)
--gpio.mode(buttons["yellow"], gpio.INT)


gpio.mode(leds["red"], gpio.OUTPUT)
gpio.mode(leds["blue"], gpio.OUTPUT)
gpio.mode(leds["green"], gpio.OUTPUT)
gpio.mode(leds["yellow"], gpio.OUTPUT)

print(" -> Desligando LEDs")
gpio.write(leds["red"], gpio.LOW)
gpio.write(leds["blue"], gpio.LOW)
gpio.write(leds["green"], gpio.LOW)
gpio.write(leds["yellow"], gpio.LOW)

function restartGame()
  print("-> Restarting Game")
  tmr.stop(2)
  attributes["velocity"] = 1000
  attributes["interval"] = 200
  attributes["sequency"] = 1
  attributes["level"] = 1
  attributes["isSaying"] = false
  attributes["isVerifying"] = false
  attributes["actualColors"] = {}
  attributes["actualResponse"] = {}
  collectgarbage()
  tmr.start(1)
end

function playerFail()
  print("-> Player Fail")
  gpio.write(leds["red"], gpio.HIGH)
  gpio.write(leds["blue"], gpio.HIGH)
  gpio.write(leds["green"], gpio.HIGH)
  gpio.write(leds["yellow"], gpio.HIGH)
  tmr.delay(300*1000)
  gpio.write(leds["red"], gpio.LOW)
  gpio.write(leds["blue"], gpio.LOW)
  gpio.write(leds["green"], gpio.LOW)
  gpio.write(leds["yellow"], gpio.LOW)
  tmr.delay(300*1000)
  gpio.write(leds["red"], gpio.HIGH)
  gpio.write(leds["blue"], gpio.HIGH)
  gpio.write(leds["green"], gpio.HIGH)
  gpio.write(leds["yellow"], gpio.HIGH)
  tmr.delay(300*1000)
  gpio.write(leds["red"], gpio.LOW)
  gpio.write(leds["blue"], gpio.LOW)
  gpio.write(leds["green"], gpio.LOW)
  gpio.write(leds["yellow"], gpio.LOW)
  tmr.delay(1000*1000)
  restartGame()
end

function nextLevel()

  tmr.stop(2)

  attributes["velocity"] = attributes["velocity"] * multipliers["velocity"]
  attributes["interval"] = attributes["interval"] * multipliers["interval"]
  attributes["sequency"] = math.ceil(attributes["sequency"] * multipliers["sequency"])
  attributes["actualColors"] = {}
  attributes["actualResponse"] = {}
  attributes["level"] = attributes["level"] + 1

  print(" - New Attributes: ")
  print("  - Velocity: " .. attributes["velocity"])
  print("  - Interval: " .. attributes["interval"])
  print("  - Sequency: " .. attributes["sequency"])

  tmr.delay(1000*1000)
  gpio.write(leds["red"], gpio.HIGH)
  gpio.write(leds["blue"], gpio.HIGH)
  gpio.write(leds["green"], gpio.HIGH)
  gpio.write(leds["yellow"], gpio.HIGH)
  sound.sPlayNote(sound_pin, "g", attributes["velocity"])
  gpio.write(leds["red"], gpio.LOW)
  gpio.write(leds["blue"], gpio.LOW)
  gpio.write(leds["green"], gpio.LOW)
  gpio.write(leds["yellow"], gpio.LOW)
  tmr.delay(2000*1000)

  tmr.start(1)
end

function saveAndVerifyAnswer(color)
  wrong = false
  print("-> Saving color")
  print(" - Color " .. color .. " saved")
  attributes["actualResponse"][table.getn(attributes["actualResponse"]) + 1] = color

  -- Verifica se concluiu
  print(" - Verifying conclusion")
  attributes["isVerifying"] = true
  print(" - Answers Saved: " .. table.getn(attributes["actualResponse"]))
  print(" - Answers Remaining: " .. (table.getn(attributes["actualResponse"]) - attributes["sequency"]))
  if table.getn(attributes["actualResponse"]) == attributes["sequency"] then
    print(" - Player Completed Answer")
    for index,value in ipairs(attributes["actualResponse"]) do
      -- Se errou uma das cores...
      if value ~= attributes["actualColors"][index] then
        wrong = true
        break
      end
    end

    if wrong then
      print(" - Wrong answer detected")
      playerFail()
      -- Fail invoca node.restart() que é uma função assíncrona
      -- Neste caso, esta função não pode continuar mais, logo é preciso forçar
      -- o retorno a última função da pilha
      return
    else
      -- Se acertou todas...
      print(" - Correct Answer Detected")
      nextLevel()
      return
    end
  end
  print(" - Player do not completed answer")
  attributes["isVerifying"] = false
end

function debounceButton(color)
  tmr.alarm(6, 200, tmr.ALARM_SINGLE, function()
    print("-> " .. color .. " pressed")
    if not attributes["isSaying"] then
      say(color)
      saveAndVerifyAnswer(color)
    end
  end)
end

--[[
  Define as interrupções
  As interrupções só são processadas quando o jogo não está "falando" as cores
]]--
gpio.trig(buttons["red"], "up", function()
  debounceButton("red")
end)

gpio.trig(buttons["green"], "up", function()
  debounceButton("green")
end)

gpio.trig(buttons["blue"], "up", function()
  debounceButton("blue")
end)

gpio.trig(buttons["yellow"], "up", function()
  debounceButton("yellow")
end)

--[[
  Inicializa o gerador randômico
]]--
math.randomseed(tmr.now())

tmr.alarm(1, 10, tmr.ALARM_SEMI, function()
  print("================ LEVEL " .. attributes["level"] .. " ================")
  attributes["actualColors"] = generate(attributes["sequency"])

  attributes["isSaying"] = true
  for index,value in ipairs(attributes["actualColors"]) do
    say(value)
  end
  attributes["isSaying"] = false

  --[[
    Entra no estado de espera pelas cores por 20 segundos, do contrário,
    o jogador perde
  ]]--
  tmr.alarm(2, 20000, tmr.ALARM_SINGLE, function()
    if not attributes["isVerifying"] then
      playerFail()
    end
  end)

  --Reinicia o alarme
  --tmr.start(1)
end)

function generate(qtd)

  print("-> Generating " .. qtd .. " colors")
  generatedColors = {}

  for i = 1, qtd do
    num = math.random(4)
    generatedColors[i] = colors[num]
    print(" - Color " .. i .. ": " .. colors[num])
  end

  print(" - End")
  return generatedColors
end

function say(color)
  print("-> Saying " .. color)
  gpio.write(leds[color], gpio.HIGH)
  print(" - Playing Sound: freq " .. notes[color] .. "  time " .. attributes["velocity"])
  sound.sPlayNote(sound_pin, notes[color], attributes["velocity"])
  gpio.write(leds[color], gpio.LOW)
  print(" - Wainting for " .. attributes["interval"] .. "ms")
  tmr.delay(attributes["interval"])
end
