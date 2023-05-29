local component = require("component")
local event = require("event")
local gpu = component.gpu
local os = require("os")

local width = 40 -- Ширина игрового поля
local height = 20 -- Высота игрового поля
local bird = {x = 5, y = height / 2, dy = 0} -- Начальное положение и скорость птицы
local pipes = {} -- Массив труб

local gapSize = 5 -- Размер промежутка между трубами
local pipeInterval = 15 -- Интервал между появлением труб

local score = 0 -- Счет игрока

-- Функция для вывода игрового поля
local function drawField()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, gpu.getResolution())

  -- Рисуем границы игрового поля
  gpu.setForeground(0x00FF00)
  gpu.set(1, 1, string.rep("█", width + 2))
  gpu.set(1, height + 2, string.rep("█", width + 2))
  for i = 2, height + 1 do
    gpu.set(1, i, "█")
    gpu.set(width + 2, i, "█")
  end

  -- Рисуем птицу
  gpu.setForeground(0xFFFF00)
  gpu.set(bird.x, bird.y, "■>")

  -- Рисуем трубы
  gpu.setForeground(0xFF00FF)
  for i = 1, #pipes do
    local pipe = pipes[i]
    gpu.set(pipe.x, 1, string.rep("█", pipe.height))
    gpu.set(pipe.x, pipe.height + gapSize + 1, string.rep("█", height - pipe.height - gapSize))
  end

  -- Выводим счет
  gpu.setForeground(0xFFFFFF)
  gpu.set(width / 2 - 1, 1, score)
end

-- Функция для обработки событий клавиатуры
local function handleKeyEvent(_, _, _, code)
  if code == 57 then -- Клавиша пробела
    bird.dy = -1 -- Птица поднимается вверх
  end
end

-- Функция для обновления состояния игры
local function updateGame()
  -- Обновляем положение птицы
  bird.y = bird.y + bird.dy

  -- Обновляем положение труб и проверяем столкновение с птицей
  for i = #pipes, 1, -1 do
    local pipe = pipes[i]
    pipe.x = pipe.x - 1

    -- Проверяем столкновение с верхней трубой
    if bird.x >= pipe.x and bird.x <= pipe.x + 1 and bird.y <= pipe.height then
      gameOver()
    end

    -- Проверяем столкновение с нижней трубой
    if bird.x >= pipe.x and bird.x <= pipe.x + 1 and bird.y >= pipe.height + gapSize then
      gameOver()
    end

    -- Удаляем трубу, если она вышла за пределы экрана
    if pipe.x <= 0 then
      table.remove(pipes, i)
      score = score + 1 -- Увеличиваем счет при успешном прохождении трубы
    end
  end

  -- Проверяем столкновение птицы с границами игрового поля
  if bird.y <= 1 or bird.y >= height + 2 then
    gameOver()
  end

  -- Генерируем новую трубу, если необходимо
  if #pipes == 0 or pipes[#pipes].x < width - pipeInterval then
    local pipeHeight = math.random(2, height - gapSize - 1)
    local pipe = {x = width, height = pipeHeight}
    table.insert(pipes, pipe)
  end
end

-- Функция для завершения игры
local function gameOver()
  gpu.setForeground(0xFF0000)
  gpu.set(width / 2 - 4, height / 2, "Game Over")
  os.sleep(2)
  os.exit()
end

-- Очищаем экран
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
gpu.fill(1, 1, gpu.getResolution())

event.listen("key_down", handleKeyEvent) -- Слушаем события клавиатуры

while true do
  drawField()
  updateGame()
  os.sleep(0.05)
end
