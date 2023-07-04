package game

import "core:fmt"
import sdl "vendor:sdl2"

FPS :: 60
FRAME_TARGET_TIME :: 1000 / FPS

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

block_size := i32((WINDOW_HEIGHT * WINDOW_WIDTH) / 20000)

game_state: GameState = {
  player1_score = 0,
  player2_score = 0,
  game_is_running = true,
  game_is_paused = false,
}

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

toggle_game_pause :: proc() {
  game_state.game_is_paused = !game_state.game_is_paused
}

process_input :: proc(keys_pressed: ^map[sdl.Keycode]int) {
  event: sdl.Event
  sdl.PollEvent(&event)

  #partial switch event.type {
    case sdl.EventType.QUIT:
      game_state.game_is_running = false
    case sdl.EventType.KEYDOWN:
      #partial switch event.key.keysym.sym {
        case sdl.Keycode.SPACE:
          keys_pressed[sdl.Keycode.SPACE] = 1
        case sdl.Keycode.ESCAPE:
          game_state.game_is_running = false
        case sdl.Keycode.p:
          toggle_game_pause()
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
        case sdl.Keycode.SPACE:
          keys_pressed[sdl.Keycode.SPACE] = 0
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

entities_are_colliding :: proc(entity1: Entity, entity2: Entity) -> bool {
  w1 := f32(entity1.width)
  h1 := f32(entity1.height)
  w2 := f32(entity2.width)
  h2 := f32(entity2.height)

  is_vertical_coll := (entity1.position[1] >= entity2.position[1] &&
                       entity1.position[1] <= entity2.position[1] + h1) ||
                      (entity1.position[1] + h1 >= entity2.position[1] &&
                       entity1.position[1] + h1 <= entity2.position[1] + h2)

  is_horizontal_coll := (entity1.position[0] >= entity2.position[0] &&
                         entity1.position[0] <= entity2.position[0] + w2) ||
                        (entity1.position[0] + w1 >= entity2.position[0] &&
                         entity1.position[0] + w1 <= entity2.position[0] + w2)
  return is_horizontal_coll && is_vertical_coll
}

get_delta_time :: proc() -> f32 {
  delta_time: f32 = (cast(f32)sdl.GetTicks() - cast(f32)last_frame_time) / 1000.0
  last_frame_time = sdl.GetTicks()
  return delta_time
}

delay :: proc() {
  delay := FRAME_TARGET_TIME - (sdl.GetTicks() - last_frame_time)

  if (delay > 0 && delay <= FRAME_TARGET_TIME) {
    sdl.Delay(delay)
  }
}

update :: proc(delta_time: f32, ball: ^Entity, paddles: ^[2]Entity, keys_pressed: map[sdl.Keycode]int) {
  if entities_are_colliding(ball^, paddles[0]) || entities_are_colliding(ball^, paddles[1]) {
    ball_bounce_horizontally(ball)
  }

  if ball.position[0] >= f32(WINDOW_WIDTH - ball.width) || ball.position[0] < 0 {
    ball_bounce_horizontally(ball)
  }

  if ball.position[1] >= f32(WINDOW_HEIGHT - ball.height) || ball.position[1] < 0 {
    ball_bounce_vertically(ball)
  }

  if right_paddle_not_moving(keys_pressed) {
    stop_paddle(&paddles[1], delta_time)
  }

  if left_paddle_not_moving(keys_pressed) {
    stop_paddle(&paddles[0], delta_time)
  }

  if keys_pressed[sdl.Keycode.UP] == 1 {
    move_paddle_up(&paddles[1])
  }

  if keys_pressed[sdl.Keycode.DOWN] == 1 {
    move_paddle_down(&paddles[1])
  }

  if keys_pressed[sdl.Keycode.w] == 1 {
    move_paddle_up(&paddles[0])
  }

  if keys_pressed[sdl.Keycode.s] == 1 {
    move_paddle_down(&paddles[0])
  }

  if keys_pressed[sdl.Keycode.SPACE] == 1{
    launch_ball(ball)
  }

  update_paddles(paddles, delta_time)
  update_ball(ball, delta_time)
}

render_playground :: proc(renderer: ^sdl.Renderer) {
  net_chunks_count := i32(800 / (block_size / 2))
  net_gap := i32(block_size)
  net: [dynamic]sdl.Rect

  for i in 0..=(net_chunks_count - 1) {
    append(&net, sdl.Rect{
      x = (WINDOW_WIDTH / 2) - (block_size / 2),
      y = block_size * 2 * i32(i),
      w = block_size,
      h = block_size,
    })
  }

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 100)
  sdl.RenderFillRects(renderer, &net[0], net_chunks_count)
}

render :: proc(renderer: ^sdl.Renderer, ball: ^Entity, paddels: ^[2]Entity) {
  sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
  sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.BLEND)
  sdl.RenderClear(renderer)

  render_playground(renderer)
  render_score(renderer, 0, 0)
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
  render(renderer, &ball, &paddles)

  keys_pressed : map[sdl.Keycode]int

  for game_state.game_is_running == true {
    delay()
    delta_time := get_delta_time()
    process_input(&keys_pressed)

    if game_state.game_is_paused == false {
      update(delta_time, &ball, &paddles, keys_pressed)
    }

    render(renderer, &ball, &paddles)
  }
}
