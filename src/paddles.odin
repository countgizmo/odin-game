package game

import "core:fmt"
import sdl "vendor:sdl2"

PADDLE_WIDTH :: 20
PADDLE_HEIGHT :: 60
PADDLE_SPEED :: 250

init_paddles :: proc() -> [2]Entity {
  paddles: [2]Entity

  paddles[0] = {
    position = {5, (WINDOW_HEIGHT / 2) - PADDLE_HEIGHT},
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    velocity = {0, 0},
  }

  paddles[1] = {
    position = {WINDOW_WIDTH - PADDLE_WIDTH - 5, (WINDOW_HEIGHT / 2) - PADDLE_HEIGHT},
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    velocity = {0, 0},
  }

  return paddles
}

render_paddels :: proc(renderer: ^sdl.Renderer, paddles: ^[2]Entity) {
  paddle_rects: [2]sdl.Rect

  paddle_rects[0] = sdl.Rect {
    x = i32(paddles[0].position[0]),
    y = i32(paddles[0].position[1]),
    w = paddles[0].width,
    h = paddles[0].height,
  }

  paddle_rects[1] = sdl.Rect {
    x = i32(paddles[1].position[0]),
    y = i32(paddles[1].position[1]),
    w = paddles[1].width,
    h = paddles[1].height,
  }

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  sdl.RenderFillRects(renderer, &paddle_rects[0], 2)
}

update_paddles :: proc(paddles: ^[2]Entity, delta_time: f32) {
  paddles[0].position += paddles[0].velocity * delta_time
  paddles[1].position += paddles[1].velocity * delta_time
}

stop_paddle :: proc(paddle: ^Entity, delta_time: f32) {
  paddle.velocity[1] = 0;
}

move_paddle_up :: proc(paddle: ^Entity) {
  paddle.velocity[1] = -PADDLE_SPEED

  if paddle.position[1] <= 0 {
    paddle.position[1] = 0
    paddle.velocity[1] = 0
  }
}

move_paddle_down :: proc(paddle: ^Entity) {
  paddle.velocity[1] = PADDLE_SPEED

  if i32(paddle.position[1]) >= WINDOW_HEIGHT - paddle.height {
    paddle.velocity[1] = 0
    paddle.position[1] = f32(WINDOW_HEIGHT - paddle.height)
  }
}
