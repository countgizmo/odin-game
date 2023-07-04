package game

import sdl "vendor:sdl2"

BALL_SPEED :: 200

init_ball :: proc() -> Entity {
  b: Entity = {
    position = {WINDOW_WIDTH / 2 + 30, 200},
    width = 15,
    height = 15,
    velocity = {0, 0}}
  return b
}

launch_ball :: proc(b: ^Entity) {
  b.velocity[0] = BALL_SPEED
  b.velocity[1] = BALL_SPEED
}

render_ball :: proc(b: ^Entity, renderer: ^sdl.Renderer) {
  ball_rect := sdl.Rect{
    x = i32(b.position[0]),
    y = i32(b.position[1]),
    w = b.width,
    h = b.height}

  sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  sdl.RenderFillRect(renderer, &ball_rect)
}

update_ball :: proc(b: ^Entity, delta_time: f32) {
  b.position = b.position + b.velocity * delta_time
}

ball_bounce_horizontally :: proc (b: ^Entity) {
  b.velocity[0] = b.velocity[0] * -1
}

ball_bounce_vertically :: proc (b: ^Entity) {
  b.velocity[1] = b.velocity[1] * -1
}
