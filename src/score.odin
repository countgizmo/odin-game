package game

import sdl "vendor:sdl2"

zero_rects := []sdl.Rect{
  { x = 300, y = 15, w = 15 * 3, h = 15},
  { x = 300, y = 30, w = 15, h = 45},
  { x = 330, y = 30, w = 15, h = 45},
  { x = 300, y = 75, w = 15 * 3, h = 15},}

eight_rects := []sdl.Rect{
  { x = 300, y = 15, w = 15 * 3, h = 15},
  { x = 300, y = 30, w = 15, h = 15},
  { x = 330, y = 30, w = 15, h = 15},
  { x = 300, y = 45, w = 15 * 3, h = 15},
  { x = 300, y = 60, w = 15, h = 15},
  { x = 330, y = 60, w = 15, h = 15},
  { x = 300, y = 75, w = 15 * 3, h = 15},}

two_blocks := block_size * 2
three_blocks := block_size * 3


render_zero :: proc(renderer: ^sdl.Renderer, start_x: i32) {
  rects := []sdl.Rect{
    { x = start_x, y = block_size, w = three_blocks, h = block_size},
    { x = start_x, y = two_blocks, w = block_size, h = three_blocks},
    { x = start_x + two_blocks, y = two_blocks, w = block_size, h = three_blocks},
    { x = start_x, y = two_blocks + three_blocks, w = three_blocks, h = block_size},
  }
  sdl.RenderFillRects(renderer, &rects[0], i32(len(rects)))
}

render_score :: proc(renderer: ^sdl.Renderer, player1: i8, player2: i8) {
  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 200)
  player1_x := i32((WINDOW_WIDTH / 2) - three_blocks - two_blocks)
  player2_x := i32((WINDOW_WIDTH / 2) + two_blocks)

  switch player1 {
    case 0: render_zero(renderer, player1_x)
  }

  switch player2 {
    case 0: render_zero(renderer, player2_x)
  }
}