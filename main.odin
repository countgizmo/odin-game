package main

import "core:fmt"
import sdl "vendor:sdl2"

window_width :: 800
window_height :: 600
game_is_running := true

initialize_window :: proc() -> ^sdl.Renderer {
  if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
    fmt.println("Error initializing SDL2")
    return nil
  }

  window := sdl.CreateWindow(
      nil,
      sdl.WINDOWPOS_CENTERED,
      sdl.WINDOWPOS_CENTERED,
      window_width,
      window_height,
      sdl.WINDOW_BORDERLESS)


  if window == nil {
    fmt.println("Error creating SDL window.")
    return nil
  }

  renderer := sdl.CreateRenderer(window, 1, sdl.RENDERER_SOFTWARE)

  if renderer == nil {
    fmt.println("Error creating SDL renderer.\n")
  }

  return renderer
}

process_input :: proc() {
  event: sdl.Event
  sdl.PollEvent(&event)

  #partial switch event.type {
    case sdl.EventType.QUIT:
      game_is_running = false
    case sdl.EventType.KEYDOWN:
      #partial switch event.key.keysym.sym {
        case sdl.Keycode.ESCAPE:
        game_is_running = false
      }
  }
}

render :: proc(renderer: ^sdl.Renderer) {
  sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
  sdl.RenderClear(renderer)

  ball_rect := sdl.Rect{x=20, y=20, w=20, h=20}

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(renderer, &ball_rect)
  sdl.RenderPresent(renderer);
}

main :: proc() {
  renderer := initialize_window()

  for game_is_running == true {
    process_input()
    render(renderer)
  }
}