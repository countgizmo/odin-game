package game

import sdl "vendor:sdl2"

BALL_SPEED :: 200

init_ball :: proc() -> Entity {
  b: Entity = {
    x = WINDOW_WIDTH / 2 + 30,
    y = 200,
    width = 15,
    height = 15,
    velocity = {0, 0}}
  return b
}

launch_ball :: proc(b: ^Entity) {
  b.velocity.x = BALL_SPEED
  b.velocity.y = BALL_SPEED
}

render_ball :: proc(b: ^Entity, renderer: ^sdl.Renderer) {
  ball_rect := sdl.Rect{
    x = b.x,
    y = b.y,
    w = b.width,
    h = b.height}

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(renderer, &ball_rect)
}

update_ball :: proc(b: ^Entity, delta_time: f32) {
  b.x = b.x + i32((b.velocity.x * delta_time))
  b.y = b.y + i32((b.velocity.y * delta_time))
}

ball_bounce_horizontally :: proc (b: ^Entity) {
  b.velocity.x = b.velocity.x * -1
}

ball_bounce_vertically :: proc (b: ^Entity) {
  b.velocity.y = b.velocity.y * -1
}
