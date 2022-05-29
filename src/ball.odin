package game

import sdl "vendor:sdl2"

Ball :: struct {
  x: i32,
  y: i32,
  width: i32,
  height: i32,
  velocity: Vector2,
}

init_ball :: proc() -> Ball {
  b: Ball = {
    x = 20,
    y = 20,
    width = 20,
    height = 20,
    velocity = {100, 100}}
  return b
}

render_ball :: proc(b: ^Ball, renderer: ^sdl.Renderer) {
  ball_rect := sdl.Rect{
    x = b.x,
    y = b.y,
    w = b.width,
    h = b.height}

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(renderer, &ball_rect)
}

update_ball :: proc(b: ^Ball, delta_time: f32) {
  b.x = b.x + i32((b.velocity.x * delta_time))
  b.y = b.y + i32((b.velocity.y * delta_time))
}

ball_bounce_horizontally :: proc (b: ^Ball) {
  b.velocity.x = b.velocity.x * -1
}

ball_bounce_vertically :: proc (b: ^Ball) {
  b.velocity.y = b.velocity.y * -1
}
