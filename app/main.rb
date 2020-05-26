require "lib/player_sprite.rb"
require "lib/enemy_sprite.rb"
require "lib/foodie_sprite.rb"

def tick(args)
  args.outputs.sounds << "sounds/background.wav" if args.tick_count == 0

  setup_game(args)

  return if args.state.reset_count >= args.tick_count

  if args.tick_count >= args.state.next_enemy
    args.outputs.sounds << "sounds/background.wav"
    args.state.enemies << EnemySprite.new(args)
    args.state.next_enemy += 1000
  end


  if args.inputs.keyboard.key_held.space
    if args.state.player.attitude == "run"
      args.state.player.attitude = "attack"
      args.state.player.path = 'sprites/buggy_attack.png'
      puts "ATTACK"
    elsif args.state.player.attitude == "attack"
      args.state.player.attitude = "run"
      args.state.player.path = 'sprites/buggy.png'
      puts "RUN"
    end
  end
  calculate_sprite_speeds(args)
  args.state.enemies.each do |enemy|
    if enemy.speed_xy >=5 || enemy.speed_up_down >= 5
      # args.outputs.sounds << "sounds/lunge.wav"
    end
  end
  player_collission = check_player_collission(args)
  player_out = check_bounds(args)
  poor_enemies = check_enemy_collissions(args.state.enemies)
  poor_enemies.each do |pe|
    pe.rotation *= -1
    args.outputs.sounds << "sounds/whup.wav"
  end

  move_sprites(args)
  reset(args) if player_out || player_collission
end

def setup_game(args)
  args.state.reset_count ||= 0
  args.state.next_enemy ||= 1000
  setup_player(args)
  setup_enemies(args)
end

def setup_player(args)
  args.state.player ||= Player.new(args.outputs)
end

def setup_enemies(args)
  args.state.enemies ||= 2.map { EnemySprite.new(args.outputs) }
end

def reset(args)
  args.outputs.static_sprites.clear
  args.state.player = nil
  args.state.enemies = nil

  screams = %w[scream1.wav]
  # args.outputs.sounds << "sounds/#{screams.sample}"
  args.state.reset_count = args.tick_count + 100
  args.state.next_enemy = args.tick_count + 1000
end

def check_player_collission(args)
  collided = false
  args.state.enemies.each do |enemy|
    enemy.register_collision -= 1 if enemy.register_collision > 1
    if enemy.rect.intersect_rect?(args.state.player.rect)
      collided = true if enemy.register_collision < 1
      enemy.register_collision = 1200
      # puts "wrecked #{args.state.player.rect} #{enemy.rect}"
    end
  end
  collided
end

def check_enemy_collissions(enemies)
  collided_enemies = []
  enemies.each do |enemy|
    next if collided_enemies.include?(enemy)
    enemies.each do |check|
      next if enemy == check
      if enemy.rect.intersect_rect? check.rect
        collided_enemies << check
      end
    end
  end
  collided_enemies
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
    enemy.angle = (args.state.tick_count % enemy.rotation_speed) * enemy.rotation
  end
end
