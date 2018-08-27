module("acclrmtr", package.seeall)

local MPU_ADDR      = 0x68; -- definição do endereço do sensor MPU6050 (0x68)
local WHO_AM_I      = 0x75; -- registrador de identificação do dispositivo
local PWR_MGMT_1    = 0x6B; -- registrador de configuração do gerenciamento de energia
local GYRO_CONFIG   = 0x1B; -- registrador de configuração do giroscópio
local ACCEL_CONFIG  = 0x1C; -- registrador de configuração do acelerômetro
local ACCEL_XOUT    = 0x3B; -- registrador de leitura do eixo X do acelerômetro

local sda, scl, id = 0, 0, 0

--[[
  Função para escrever um valor em um registrador
]]--
local function write(reg, value)
  i2c.start(id)
  i2c.address(id, MPU_ADDR, i2c.TRANSMITTER)
  i2c.write(id, reg)
  i2c.write(id, value)
  i2c.stop(id)
end

--[[
  Função para ler o valor de um registrador
]]--
local function read(reg)
  local data = 0

  i2c.start(id)
  i2c.address(id, MPU_ADDR, i2c.TRANSMITTER)
  i2c.write(id, reg)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, MPU_ADDR, i2c.RECEIVER)
  data = i2c.read(id, 1)
  i2c.stop(id)

  return data
end

--[[
  Função para configurar o sleep bit
]]--
function setSleepOff()
  write(PWR_MGMT_1, 0)
end

--[[
  Função para configurar as escalas do giroscópio
  registrador da escala do giroscópio: 0x1B[4:3]
  0 é 250°/s

  FS_SEL  Full Scale    Range
    0     ± 250 °/s   0b00000000
    1     ± 500 °/s   0b00001000
    2     ± 1000 °/s  0b00010000
    3     ± 2000 °/s  0b00011000
]]--
function setGyroScale()
  write(GYRO_CONFIG, 0)
end

--[[
  Função para configurar as escalas do acelerômetro
  registrador da escala do acelerômetro: 0x1C[4:3]
  0 é 250°/s

  AFS_SEL   Full Scale Range
    0           ± 2g            0b00000000
    1           ± 4g            0b00001000
    2           ± 8g            0b00010000
    3           ± 16g           0b00011000
]]--
function setAccelScale()
  write(ACCEL_CONFIG, 0)
end

local function initMPU()
  i2c.setup(id, sda, scl, i2c.SLOW)
  setSleepOff()
  setGyroScale()
  setAccelScale()
end

function checkMPU()
  data = read(MPU_ADDR)

  print("")
end

function setup(id, sda, scl)

  #sda = sda
  #scl = scl
  #id = id

  print("iniciando configuração")

  initMPU()
  checkMPU(MPU_ADDR)

  print("fim da configuração")
end
