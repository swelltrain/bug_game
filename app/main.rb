def tick(args)
  setup_game(args)
  # reset(args)
  calculate_player_speeds(args)
  move_player(args)
  player_out = check_bounds(args)
  reset(args) && setup_environment(args) if player_out
  args.outputs.sprites << [args.state.player.x, args.state.player.y, 32, 32, "sprites/buggy.png"]
  # args.outputs.sprites << [args.state.squishy.x, args.state.squishy.y, 128, 101, "sprites/squishy.png"]
end

def setup_player(args)
  args.state.player.x ||= 100
  args.state.player.y ||= 100
  args.state.player.speed_xy ||= 0
  args.state.player.speed_up_down ||= 0
end

def setup_game(args)
  setup_player(args)
  setup_environment(args)
end

def setup_environment(args)
  grid = args.grid
  args.state.squishy.x ||= rand * grid.w
  args.state.squishy.y ||= rand * grid.h
end

def reset(args)
  grid = args.grid
  args.state.player.x = rand * grid.w
  args.state.player.y = rand * grid.h
  args.state.player.speed_xy = 0
  args.state.player.speed_up_down = 0

  args.state.squishy.x = rand * grid.w
  args.state.squishy.y = rand * grid.h
  screams = %w[scream1.wav scream2.wav scream3.wav]
  args.outputs.sounds << "sounds/#{screams.sample}"
end

def check_bounds(args)
  args.state.player.x >= 1190 || args.state.player.x <= -20 ||
  args.state.player.y >= 700 || args.state.player.y <= 0
end

def calculate_player_speeds(args)
  if args.inputs.keyboard.key_held.right
    args.state.keyboard.key_xy = "right"
    args.state.player.speed_xy += 0.5 unless args.state.player.speed_xy > 10
  end
  if args.inputs.keyboard.key_held.left
    args.state.keyboard.key_xy = "left"
    args.state.player.speed_xy -= 0.5 unless (args.state.player.speed_xy * -1) > 10
  end

  if args.inputs.keyboard.key_held.up
    args.state.keyboard.key_up_down = "up"
    args.state.player.speed_up_down += 0.5 unless args.state.player.speed_up_down > 10
  end
  if args.inputs.keyboard.key_held.down
    args.state.keyboard.key_up_down = "down"
    args.state.player.speed_up_down -= 0.5 unless (args.state.player.speed_up_down * -1) > 10
  end
end

def move_player(args)
  if args.state.keyboard.key_xy == "right"
    args.state.player.x += args.state.player.speed_xy unless args.state.player.x >= 1200
  end
  if args.state.keyboard.key_xy == "left"
    args.state.player.x += args.state.player.speed_xy unless args.state.player.x <= -30
  end

  if args.state.keyboard.key_up_down == "up"
    args.state.player.y += args.state.player.speed_up_down unless args.state.player.y >= 720
  end
  if args.state.keyboard.key_up_down == "down"
    args.state.player.y += args.state.player.speed_up_down unless args.state.player.y <= -30
  end
end
