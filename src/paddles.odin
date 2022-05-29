package game

import sdl "vendor:sdl2"

PADDLE_WIDTH :: 20
PADDLE_HEIGHT :: 60


Paddle :: struct {
  x: i32,
  y: i32,
  width: i32,
  height: i32,
  velocity: Vector2,
}

init_paddles :: proc() -> [2]Paddle {
  paddles: [2]Paddle

  paddles[0] = {
    x = 5,
    y = (WINDOW_HEIGHT / 2) - PADDLE_HEIGHT,
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    velocity = {0, 0},
  }

  paddles[1] = {
    x = WINDOW_WIDTH - PADDLE_WIDTH - 5,
    y = (WINDOW_HEIGHT / 2) - PADDLE_HEIGHT,
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    velocity = {0, 0},
  }

  return paddles
}

render_paddels :: proc(renderer: ^sdl.Renderer, paddles: ^[2]Paddle) {
  paddle_rects: [2]sdl.Rect

  paddle_rects[0] = sdl.Rect {
    x = paddles[0].x,
    y = paddles[0].y,
    w = paddles[0].width,
    h = paddles[0].height,
  }

  paddle_rects[1] = sdl.Rect {
    x = paddles[1].x,
    y = paddles[1].y,
    w = paddles[1].width,
    h = paddles[1].height,
  }

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  sdl.RenderFillRects(renderer, &paddle_rects[0], 2)
}

update_paddles :: proc(paddles: ^[2]Paddle, delta_time: f32) {
  paddles[0].y = paddles[0].y + i32((paddles[0].velocity.y * delta_time))
  paddles[1].y = paddles[1].y + i32((paddles[1].velocity.y * delta_time))
}

stop_paddle :: proc(paddle: ^Paddle, delta_time: f32) {
  paddle.velocity.y = 0;
}

move_paddle_up :: proc(paddle: ^Paddle, delta_time: f32) {
  paddle.velocity.y = paddle.velocity.y + (-250 * 2 * delta_time)

  if paddle.y < 10 {
    paddle.velocity.y = 0
  }
}

move_paddle_down :: proc(paddle: ^Paddle, delta_time: f32) {
  paddle.velocity.y = paddle.velocity.y + (250 * 2 * delta_time)

  if paddle.y > WINDOW_HEIGHT - paddle.height - 10 {
    paddle.velocity.y = 0
  }
}
