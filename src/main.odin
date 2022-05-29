package game

import "core:fmt"
import sdl "vendor:sdl2"

FPS :: 60
FRAME_TARGET_TIME :: 1000 / FPS

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

game_is_running := true
last_frame_time: u32 = 0

initialize_window :: proc() -> ^sdl.Renderer {
  if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
    fmt.println("Error initializing SDL2")
    return nil
  }

  window := sdl.CreateWindow(
      nil,
      sdl.WINDOWPOS_CENTERED,
      sdl.WINDOWPOS_CENTERED,
      WINDOW_WIDTH,
      WINDOW_HEIGHT,
      sdl.WINDOW_BORDERLESS)


  if window == nil {
    fmt.println("Error creating SDL window.")
    return nil
  }

  renderer := sdl.CreateRenderer(window, 1, sdl.RENDERER_SOFTWARE)

  if renderer == nil {
    fmt.println("Error creating SDL renderer.")
  }

  return renderer
}

process_input :: proc(keys_pressed: ^map[sdl.Keycode]int) {
  event: sdl.Event
  sdl.PollEvent(&event)

  #partial switch event.type {
    case sdl.EventType.QUIT:
      game_is_running = false
    case sdl.EventType.KEYDOWN:
      #partial switch event.key.keysym.sym {
        case sdl.Keycode.ESCAPE:
          game_is_running = false
        case sdl.Keycode.UP:
          keys_pressed[sdl.Keycode.UP] = 1
        case sdl.Keycode.DOWN:
          keys_pressed[sdl.Keycode.DOWN] = 1
        case sdl.Keycode.w:
          keys_pressed[sdl.Keycode.w] = 1
        case sdl.Keycode.s:
          keys_pressed[sdl.Keycode.s] = 1
      }
    case sdl.EventType.KEYUP:
      #partial switch event.key.keysym.sym {
        case sdl.Keycode.UP:
          keys_pressed[sdl.Keycode.UP] = 0
        case sdl.Keycode.DOWN:
          keys_pressed[sdl.Keycode.DOWN] = 0
        case sdl.Keycode.w:
          keys_pressed[sdl.Keycode.w] = 0
        case sdl.Keycode.s:
          keys_pressed[sdl.Keycode.s] = 0
      }
  }
}

left_paddle_not_moving :: proc(keys_pressed: map[sdl.Keycode]int) -> bool {
  return (keys_pressed[sdl.Keycode.w] == 0) && (keys_pressed[sdl.Keycode.s] == 0)
}

right_paddle_not_moving :: proc(keys_pressed: map[sdl.Keycode]int) -> bool {
  return (keys_pressed[sdl.Keycode.UP] == 0) && (keys_pressed[sdl.Keycode.DOWN] == 0)
}

update :: proc(ball: ^Ball, paddles: ^[2]Paddle, keys_pressed: map[sdl.Keycode]int) {
  delay := FRAME_TARGET_TIME - (sdl.GetTicks() - last_frame_time)

  if (delay > 0 && delay <= FRAME_TARGET_TIME) {
    sdl.Delay(delay)
  }

  // delta_time in seconds
  delta_time: f32 = (cast(f32)sdl.GetTicks() - cast(f32)last_frame_time) / 1000.0
  last_frame_time = sdl.GetTicks()

  if ball.x >= (WINDOW_WIDTH - ball.width) || ball.x < 0 {
    ball_bounce_horizontally(ball)
  }

  if ball.y >= (WINDOW_HEIGHT - ball.height) || ball.y < 0 {
    ball_bounce_vertically(ball)
  }

  if right_paddle_not_moving(keys_pressed) {
    stop_paddle(&paddles[1], delta_time)
  }

  if left_paddle_not_moving(keys_pressed) {
    stop_paddle(&paddles[0], delta_time)
  }

  if keys_pressed[sdl.Keycode.UP] == 1 {
    move_paddle_up(&paddles[1], delta_time)
  }

  if keys_pressed[sdl.Keycode.DOWN] == 1 {
    move_paddle_down(&paddles[1], delta_time)
  }

  if keys_pressed[sdl.Keycode.w] == 1 {
    move_paddle_up(&paddles[0], delta_time)
  }

  if keys_pressed[sdl.Keycode.s] == 1 {
    move_paddle_down(&paddles[0], delta_time)
  }

  update_paddles(paddles, delta_time)
  update_ball(ball, delta_time)
}

render_playground :: proc(renderer: ^sdl.Renderer) {
  NET_CHUNKS_COUNT :: 15
  net_gap := i32(WINDOW_HEIGHT / NET_CHUNKS_COUNT)
  net: [NET_CHUNKS_COUNT]sdl.Rect


  for i in 0..=(NET_CHUNKS_COUNT - 1) {
    net[i] = sdl.Rect{
      x = (WINDOW_WIDTH / 2) - (net_gap / 2),
      y = net_gap * i32(i),
      w = net_gap / 2,
      h = net_gap / 2}
  }

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 100)
  sdl.RenderFillRects(renderer, &net[0], NET_CHUNKS_COUNT)
}

render :: proc(renderer: ^sdl.Renderer, ball: ^Ball, paddels: ^[2]Paddle) {
  sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
  sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.BLEND)
  sdl.RenderClear(renderer)

  render_playground(renderer)
  render_paddels(renderer, paddels)
  render_ball(ball, renderer)

  sdl.RenderPresent(renderer);
}

main :: proc() {
  renderer := initialize_window()

  if renderer == nil {
    fmt.println("Error initializing renderer.")
    return
  }

  ball := init_ball()
  paddles := init_paddles()
  keys_pressed : map[sdl.Keycode]int

  for game_is_running == true {
    process_input(&keys_pressed)
    update(&ball, &paddles, keys_pressed)
    render(renderer, &ball, &paddles)
  }
}