local component = require("component")
local event = require("event")
local gpu = component.gpu
local os = require("os")

local width = 40 -- Ширина игрового поля
local height = 20 -- Высота игрового поля
local paddleWidth = 1 -- Ширина ракетки
local paddleHeight = 5 -- Высота ракетки
local ball = {x = width / 2, y = height / 2, dx = 1, dy = 1} -- Начальное положение и скорость мяча
local leftPaddle = {x = 1, y = height / 2 - paddleHeight / 2} -- Начальное положение левой ракетки
local rightPaddle = {x = width - paddleWidth, y = height / 2 - paddleHeight / 2} -- Начальное положение правой ракетки
local leftScore = 0 -- Счет левого игрока
local rightScore = 0 -- Счет правого игрока

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

  -- Рисуем левую ракетку
  gpu.setForeground(0xFFFF00)
  for i = 0, paddleHeight - 1 do
    gpu.set(leftPaddle.x + 1, leftPaddle.y + i + 1, "█")
  end

  -- Рисуем правую ракетку
  gpu.setForeground(0xFF00FF)
  for i = 0, paddleHeight - 1 do
    gpu.set(rightPaddle.x + 1, rightPaddle.y + i + 1, "█")
  end

  -- Рисуем мяч
  gpu.setForeground(0x00FFFF)
  gpu.set(ball.x + 1, ball.y + 1, "█")

  -- Выводим счет
  gpu.setForeground(0xFFFFFF)
  gpu.set(width / 2 - 1, 1, leftScore .. " - " .. rightScore)
end

-- Функция для обработки событий клавиатуры
local function handleKeyEvent(_, _, _, code)
  if code == 200 and leftPaddle.y > 1 then -- Клавиша вверх
    leftPaddle.y = leftPaddle.y - 1
  elseif code == 208 and leftPaddle.y + paddleHeight < height then -- Клавиша вниз
    leftPaddle.y = leftPaddle.y + 1
  end
end

-- Функция для обновления состояния игры
local function updateGame()
  -- Обновляем положение мяча
  ball.x = ball.x + ball.dx
  ball.y = ball.y + ball.dy

  -- Проверяем столкновение мяча со стенками
  if ball.y <= 1 or ball.y >= height then
    ball.dy = -ball.dy
  end

  -- Проверяем столкновение мяча с ракетками
  if (ball.x == leftPaddle.x + paddleWidth and ball.y >= leftPaddle.y and ball.y <= leftPaddle.y + paddleHeight)
    or (ball.x == rightPaddle.x - 1 and ball.y >= rightPaddle.y and ball.y <= rightPaddle.y + paddleHeight) then
    ball.dx = -ball.dx
  end

  -- Проверяем выход мяча за границы поля
  if ball.x < 0 then -- Мяч слева от поля
    rightScore = rightScore + 1
    os.sleep(1)
    resetGame()
  elseif ball.x > width - 1 then -- Мяч справа от поля
    leftScore = leftScore + 1
    os.sleep(1)
    resetGame()
  end
end

-- Функция для сброса игры в начальное состояние
local function resetGame()
  ball.x = width / 2
  ball.y = height / 2
  ball.dx = -ball.dx
  ball.dy = -ball.dy
  leftPaddle.y = height / 2 - paddleHeight / 2
  rightPaddle.y = height / 2 - paddleHeight / 2
end

-- Очищаем экран
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
gpu.fill(1, 1, gpu.getResolution())

-- Задаем разрешение экрана
gpu.setResolution(width + 2, height + 2)

event.listen("key_down", handleKeyEvent) -- Слушаем события клавиатуры

while true do
  drawField()
  updateGame()
  os.sleep(0.05)
end
