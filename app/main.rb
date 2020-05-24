require "lib/player_sprite.rb"
require "lib/enemy_sprite.rb"

def tick(args)
  setup_game(args)

  calculate_sprite_speeds(args)
  move_sprites(args)
  player_out = check_bounds(args)
  reset(args) if player_out
end

def setup_game(args)
  setup_player(args)
  setup_enemies(args)
end

def setup_player(args)
  args.state.player ||= Player.new(args.outputs)
end

def setup_enemies(args)
  args.state.enemies ||= 10.map { EnemySprite.new(args.outputs) }
end

def reset(args)
  args.outputs.static_sprites.clear
  args.state.player = nil
  args.state.enemies = nil

  screams = %w[scream1.wav]
  args.outputs.sounds << "sounds/#{screams.sample}"
end

def check_bounds(args)
  args.state.player.x >= 1190 || args.state.player.x <= -20 ||
  args.state.player.y >= 700 || args.state.player.y <= 0
end

def calculate_sprite_speeds(args)
  args.state.player.calculate_speed(args.inputs.keyboard.key_held)
  args.state.enemies.each do |enemy|
    enemy.determine_move(args)
  end
end

def move_sprites(args)
  args.state.player.move!
  args.state.enemies.each do |enemy|
    enemy.move!
  end
end
