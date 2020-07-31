--[[
                CONTROLS
                SPACE TO START
  PLAYER 1           |      PLAYER 2
  UP -> 'W'          |      UP -> ARROW_UP
  DOWN -> 'S'        |      DOWN -> ARROW_DOWN
  IA -> ARROW_LEFT   |      IA -> ARROW_RIGHT

]]


push = require 'push'

Class = require 'class'

require 'Ball'

require 'Paddle'

--constants
W_WIDTH = 1280
W_HEIGHT = 720

V_WIDTH = 432
V_HEIGHT = 243

PADDLE_SPEED = 200

--init
function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  small_font = love.graphics.newFont('font.ttf', 20)
  big_font = love.graphics.newFont('font.ttf', 40)


  sounds = {
      ['paddle_hit'] = love.audio.newSource('sounds/paddle.wav', 'static'),
      ['wall_hit'] = love.audio.newSource('sounds/wall.wav', 'static'),
      ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
  }
  --new seed
  math.randomseed(os.time())

  push:setupScreen(V_WIDTH, V_HEIGHT, W_WIDTH, W_HEIGHT, {fullscreen = false,resizable = true, vsync = true})


  player_1 = Paddle(10, 30, 5, 20)
  player_2 = Paddle(V_WIDTH-10, V_HEIGHT-30, 5, 20)

  ball = Ball(V_WIDTH/2-2, V_HEIGHT/2-2, 4, 4)

  player_1_score = 0
  player_2_score = 0

  serve = math.random(1,2)
  win = 0

  player_1_ia = false
  player_2_ia = false

  love.window.setTitle('Pong!')

  game_state = 'start'
end

function love.update(dt)
  --move p1
  if player_1_ia then
    if game_state == 'play' then
      if ball.y < player_1.y+5 then
        player_1.dy = -PADDLE_SPEED
      elseif ball.y > player_1.y+15 then
        player_1.dy = PADDLE_SPEED
      else
        player_1.dy = 0
      end
    end
  else
    if love.keyboard.isDown('w') then
      player_1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
      player_1.dy = PADDLE_SPEED
    else
      player_1.dy = 0
    end
  end
  --move p2
  if player_2_ia then
    if game_state == 'play' then
      if ball.y < player_2.y+5 then
        player_2.dy = -PADDLE_SPEED
      elseif ball.y > player_2.y+15 then
        player_2.dy = PADDLE_SPEED
      else
        player_2.dy = 0
      end
    end
  else
    if love.keyboard.isDown('up') then
      player_2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
      player_2.dy = PADDLE_SPEED
    else
      player_2.dy = 0
    end
  end
  if game_state == 'serve' then
    ball.dy = math.random(-50,50)
    if serve == 1 then
      ball.dx = math.random(140,200)
    else
      ball.dx = -math.random(140,200)
    end
  elseif game_state == 'play' then

    if ball:collides(player_1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player_1.x + 5
      if ball.dy < 0 then
        ball.dy = -math.random(10,150)
      else
        ball.dy = math.random(10,150)
      end
      sounds['paddle_hit']:play()
    end
    if ball:collides(player_2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player_2.x - 4

      if ball.dy < 0 then
        ball.dy = -math.random(10,150)
      else
        ball.dy = math.random(10,150)
      end
      sounds['paddle_hit']:play()
    end
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end
    if ball.y >= V_HEIGHT-4 then
      ball.y = V_HEIGHT-4
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end

    if ball.x <= 0 then
      ball:reset()
      player_1:reset()
      player_2:reset()
      player_2_score = player_2_score + 1
      game_state = 'serve'
      serve = 1
      sounds['score']:play()
    end
    if ball.x >= V_WIDTH-4 then
      ball:reset()
      player_1:reset()
      player_2:reset()
      player_1_score = player_1_score + 1
      game_state = 'serve'
      serve = 2
      sounds['score']:play()
    end
    ball:update(dt)
  end

  if player_1_score == 10 then
    game_state = 'done'
    win = 1
  elseif player_2_score == 10 then
    game_state = 'done'
    win = 2
  end

  player_1:update(dt)
  player_2:update(dt)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'space' then
      if game_state == 'start' then
          game_state = 'play'
      elseif game_state == 'play' then
          game_state = 'start'
          --reset ball position and move
          ball:reset()
      elseif game_state == 'serve' then
        game_state = 'play'
      elseif game_state == 'done' then
        game_state = 'play'
        player_1_score = 0
        player_2_score = 0
        win = 0
        ball:reset()

        if win == 1 then
          serve = 2
        else
          serve = 1
        end

      end
  end
  if game_state == 'start' then
    if key == 'left' then
      if player_1_ia then
        player_1_ia = false
      else
        player_1_ia = true
      end
    elseif key == 'right' then
      if player_2_ia then
        player_2_ia = false
      else
        player_2_ia = true
      end
    end
  end
end

--render--
function love.draw()

  push:apply('start')

  --draw texts
  if game_state == 'start' then
    love.graphics.setFont(small_font)
    love.graphics.printf('PRESS SPACE',0, 0 ,V_WIDTH,'center')

    if player_1_ia then
      love.graphics.printf('PLAYER 1 IA ENABLE',0, 40 ,V_WIDTH,'center')
    else
      love.graphics.printf('PLAYER 1 IA DISABLE',0, 40 ,V_WIDTH,'center')
    end
    if player_2_ia then
      love.graphics.printf('PLAYER 2 IA ENABLE',0, 60 ,V_WIDTH,'center')
    else
      love.graphics.printf('PLAYER 2 IA DISABLE',0, 60 ,V_WIDTH,'center')
    end

  elseif game_state == 'play' then
    love.graphics.setFont(small_font)
    love.graphics.printf('GOOD LUCK!',0, 0 ,V_WIDTH,'center')
  elseif game_state == 'serve' then
    love.graphics.setFont(small_font)
    love.graphics.printf('PLAYER '..tostring(serve).."'s serve",0, 0 ,V_WIDTH,'center')
    love.graphics.printf('PRESS SPACE',0, 20 ,V_WIDTH,'center')
  elseif game_state == 'done' then
    love.graphics.setFont(big_font)
    love.graphics.printf('Player '..tostring(win)..' win!',0, 0 ,V_WIDTH,'center')
    love.graphics.setFont(small_font)
    love.graphics.printf('PRESS SPACE',0, 20 ,V_WIDTH,'center')
  end

  love.graphics.setFont(big_font)
  love.graphics.print(tostring(player_1_score), V_WIDTH/2-50, V_HEIGHT/3)
  love.graphics.print(tostring(player_2_score), V_WIDTH/2+30, V_HEIGHT/3)

  --draw objs
  player_1:render()
  player_2:render()
  ball:render()

  displayFPS()

  push:apply('end')
end

function displayFPS()
  love.graphics.setFont(small_font)
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 4, 2)
end

function love.resize(w, h)
  push:resize(w,h)
end
