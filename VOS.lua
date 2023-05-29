local component = require("component")
local event = require("event")
local gpu = component.gpu
local os = require("os")

-- Функция для вывода заставки
local function drawSplashScreen()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, gpu.getResolution())
  gpu.set(1, 12, "Veco OS")
  os.sleep(2) -- Задержка для отображения заставки
end

-- Функция для вывода меню игр
local function drawGameMenu()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, gpu.getResolution())
  gpu.set(1, 5, "=============================")
  gpu.set(1, 7, "Veco OS Game Menu:")
  gpu.set(1, 9, "1. Snake")
  gpu.set(1, 10, "2. Pong")
  gpu.set(1, 11, "3. Flappy Bird")
  gpu.set(1, 13, "Enter the number of the game to start:")
  gpu.set(1, 5, "=============================")
end

-- Функция для запуска игры Snake
local function runSnake()
  -- Здесь может быть код для запуска игры Snake
  print("Starting Snake...")
end

-- Функция для запуска игры Pong
local function runPong()
  -- Здесь может быть код для запуска игры Pong
  print("Starting Pong...")
end

-- Функция для запуска игры Flappy Bird
local function runFlappyBird()
  -- Здесь может быть код для запуска игры Flappy Bird
  print("Starting Flappy Bird...")
end

-- Запуск заставки
drawSplashScreen()

-- Вывод меню игр
drawGameMenu()

-- Ожидаем нажатия клавиши
local _, _, _, _, _, key = event.pull("key_down")
if key == 2 then -- Клавиша 1 для игры Snake
  runSnake()
elseif key == 3 then -- Клавиша 2 для игры Pong
  runPong()
elseif key == 4 then -- Клавиша 3 для игры Flappy Bird
  runFlappyBird()
end
