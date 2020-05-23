require "lib/my_sprite.rb"

def tick(args)
  setup_game(args)

  calculate_player_speeds(args)
  args.state.player.move!
  player_out = check_bounds(args)
  reset(args) if player_out
end

def setup_game(args)
  setup_player(args)
end

def setup_player(args)
  args.state.player ||= Player.new(args.outputs)
end

def reset(args)
  args.outputs.static_sprites.clear
  args.state.player = nil

  screams = %w[scream1.wav]
  args.outputs.sounds << "sounds/#{screams.sample}"
end

def check_bounds(args)
  args.state.player.x >= 1190 || args.state.player.x <= -20 ||
  args.state.player.y >= 700 || args.state.player.y <= 0
end

def calculate_player_speeds(args)
  args.state.player.calculate_speed(args.inputs.keyboard.key_held)
end
