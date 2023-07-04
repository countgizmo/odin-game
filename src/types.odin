package game

Vector2 :: [2]f32

Entity :: struct {
  position: Vector2,
  width: i32,
  height: i32,
  velocity: Vector2,
}

GameState :: struct {
  player1_score: i8,
  player2_score: i8,
  game_is_running: bool,
  game_is_paused: bool,
}
