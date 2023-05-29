local component = require("component")
local event = require("event")
local gpu = component.gpu
local os = require("os")

local width = 40 -- Ширина игрового поля
local height = 20 -- Высота игрового поля
local snake = {{x = 10, y = 10}} -- Начальное положение змейки
local direction = "right" -- Начальное направление движения
local gameover = false -- Флаг окончания игры

-- Функция для вывода игрового поля
local function drawField()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, gpu.getResolution())

  -- Рисуем границу
  gpu.setForeground(0x00FF00)
  gpu.set(1, 1, string.rep("█", width + 2))
  gpu.set(1, height + 2, string.rep("█", width + 2))
  for i = 2, height + 1 do
    gpu.set(1, i, "█")
    gpu.set(width + 2, i, "█")
  end

  -- Рисуем змейку
  gpu.setForeground(0xFFFF00)
  for _, segment in ipairs(snake) do
    gpu.set(segment.x + 1, segment.y + 1, "█")
  end
end

-- Функция для обработки событий клавиатуры
local function handleKeyEvent(_, _, _, code)
  if code == 200 and direction ~= "down" then -- Клавиша вверх
    direction = "up"
  elseif code == 208 and direction ~= "up" then -- Клавиша вниз
    direction = "down"
  elseif code == 203 and direction ~= "right" then -- Клавиша влево
    direction = "left"
  elseif code == 205 and direction ~= "left" then -- Клавиша вправо
    direction = "right"
  end
end

-- Функция для обновления состояния игры
local function updateGame()
  local head = {x = snake[1].x, y = snake[1].y}

  -- Обновляем положение головы змейки в зависимости от направления
  if direction == "up" then
    head.y = head.y - 1
  elseif direction == "down" then
    head.y = head.y + 1
  elseif direction == "left" then
    head.x = head.x - 1
  elseif direction == "right" then
    head.x = head.x + 1
  end

  -- Проверяем столкновение с границей игрового поля
  if head.x < 0 or head.x >= width or head.y < 0 or head.y >= height then
    gameover = true
    return
  end

  -- Проверяем столкновение с самой собой
  for i = 2, #snake do
    if head.x == snake[i].x and head.y == snake[i].y then
      gameover = true
      return
    end
  end

  table.insert(snake, 1, head) -- Добавляем новую голову в начало змейки
  if head.x == food.x and head.y == food.y then -- Проверяем съедание пищи
    food = generateFood() -- Генерируем новую пищу
  else
    table.remove(snake) -- Удаляем хвост змейки
  end
end

-- Функция для генерации пищи
local function generateFood()
  local food = {}

  repeat
    food.x = math.random(width)
    food.y = math.random(height)
  until not isOnSnake(food)

  gpu.setForeground(0xFF0000)
  gpu.set(food.x + 1, food.y + 1, "█")

  return food
end

-- Функция для проверки, находится ли координата на змейке
local function isOnSnake(coord)
  for _, segment in ipairs(snake) do
    if coord.x == segment.x and coord.y == segment.y then
      return true
    end
  end
  return false
end

-- Функция для запуска игры
local function runSnakeGame()
  gpu.setResolution(width + 2, height + 2) -- Устанавливаем разрешение экрана
  gpu.setBackground(0x000000)
  os.sleep(1)

  event.listen("key_down", handleKeyEvent) -- Слушаем события клавиатуры

  -- Генерируем первую пищу
  food = generateFood()

  while not gameover do
    drawField()
    updateGame()
    os.sleep(0.1)
  end

  event.ignore("key_down", handleKeyEvent) -- Прекращаем прослушивание событий клавиатуры

  -- Выводим сообщение об окончании игры
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.set(width / 2 - 5, height / 2, "Game Over!")
  gpu.set(width / 2 - 7, height / 2 + 1, "Press any key to exit.")
  event.pull("key_down") -- Ожидаем нажатия клавиши для выхода

  gpu.setResolution(gpu.maxResolution()) -- Восстанавливаем исходное разрешение экрана
end

runSnakeGame() -- Запускаем игру "Змейка"
