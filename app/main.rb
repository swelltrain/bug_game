require "lib/base_enemy_sprite.rb"
require "lib/player_sprite.rb"
require "lib/enemy_sprite.rb"
require "lib/slow_enemy.rb"
require "lib/foodie_sprite.rb"
require "lib/chasing_enemy_sprite.rb"
require "lib/star_sprite.rb"
require "lib/homer_sprite.rb"

def tick(args)
  if args.tick_count == 0
    args.outputs.sounds << "sounds/background.wav"
    args.state.homer_available = true
  end

  return if args.state.reset_count >= args.tick_count

  setup_game(args)

  if args.state.player.attitude == "attack"
    args.state.player.decay_attack
    if args.state.player.running_out_of_attack?
      args.outputs.sounds << "sounds/gasp2.wav"
    end
    if args.state.player.decay_attack <= 0
      args.state.player.run!
    end
  end

  if args.tick_count >= args.state.next_food
    args.state.food = FoodieSprite.new(args)
    args.state.next_food += [400,600,800,1200,1200,2400].sample
    # args.state.next_food += [400,1000].sample + args.tick_count
    args.outputs.sounds << "sounds/powerup.wav"
  end

  if args.tick_count >= args.state.next_enemy && args.state.total_enemies < 30
    # args.outputs.sounds << "sounds/background.wav"
    if rand < 0.2
      args.state.enemies << ChasingEnemySprite.new(args.outputs)
    elsif rand <= 0.3
      args.state.enemies << EnemySprite.new(args.outputs)
    else
      args.state.enemies << SlowEnemySprite.new(args.outputs)
    end
    args.state.next_enemy += [0,100,100,100,200,300,500,800].sample
    args.state.total_enemies += 1
    # args.outputs.sounds << "sounds/background.wav"
  end

  if args.tick_count >= args.state.next_homer && args.state.homer_available
    puts "homer avail #{args.state.homer_available}"
    args.state.star = StarSprite.new(args)
    args.state.homer_available = false
  end

  calculate_sprite_speeds(args)
  args.state.enemies.each do |enemy|
    if enemy.near_player?(args.state.player)
      enemy.lunging = 3
    else
      enemy.lunging = 0
    end
  end
  player_collission = check_player_collission(args)
  player_out = check_bounds(args)
  poor_enemies = check_enemy_collissions(args.state.enemies)
  poor_enemies.each do |pe|
    pe.rotation *= -1
    pe.decrement_speed_max
    pe.injured = true
    args.outputs.sounds << "sounds/whup.wav"
  end

  move_sprites(args)
  if args.state.food
    args.outputs.sprites << args.state.food
  end

  if args.state.food
    if args.state.player.rect.intersect_rect?(args.state.food.rect)
      args.state.food = false
      args.state.player.attack!
      args.state.player.increment_health(10)
      args.state.score += 50
      args.outputs.sounds << "sounds/eat_power_up.wav"
    end
  end

  if args.state.star
    args.outputs.sprites << args.state.star
    if args.state.player.rect.intersect_rect?(args.state.star.rect)
      # emit a homer sprite with x and y of player x and y
      # args.state.star = nil
      args.state.score += 50
      args.state.homer_available = true
    end
  end

  args.state.enemies.each { |enemy| args.outputs.sprites << enemy }
  if player_collission && args.state.player.attitude == "attack"
    args.state.enemies.reject! { |e| e == player_collission }

    args.state.player.attack!
    args.state.player.increment_health(5)
    args.state.score += args.state.player.health
    args.state.total_enemies -= 1
    args.outputs.sounds << "sounds/chomp.wav"
  end
  args.outputs.solids << [0, 690, 1280, 30]

  args.outputs.labels << {
    x:              1000,
    y:              715,
    text:           "High Score: #{args.state.high_score} | Score: #{args.state.score} | Health: #{args.state.player.health}",
    size_enum:      0,
    alignment_enum: 1,
    r:              255,
    g:              255,
    b:              255,
  }
  args.state.player.decrement_hit

  if (player_collission && args.state.player.attitude == "run")
    initial = args.state.enemies.count
    args.state.enemies.reject! { |e| e == player_collission }
    args.outputs.sounds << "sounds/glass_break.wav"
    args.state.total_enemies -= (initial - args.state.enemies.count)

    args.state.player.previous_key_xy = player_collission.previous_key_xy
    args.state.player.previous_key_up_down = player_collission.previous_key_up_down
    args.state.player.speed_xy = (player_collission.speed_xy * 1.2)
    args.state.player.speed_up_down = (player_collission.speed_up_down * 1.2)
    args.state.player.hit = 30

    args.state.player.decrement_health(10)
  end

  reset(args) if player_out || args.state.player.health == 0

end

def setup_game(args)
  args.state.reset_count ||= 0
  args.state.next_enemy ||= 1000
  args.state.next_food ||= 400
  args.state.next_homer ||= 400
  # args.state.homer_available = true
  args.state.food ||= false
  args.state.star ||= false
  args.state.score ||= 0
  args.state.total_enemies ||= 20
  args.state.high_score ||= 0
  setup_player(args)
  setup_enemies(args)
end

def setup_player(args)
  args.state.player ||= Player.new(args.outputs)
end

def setup_enemies(args)
  args.state.enemies ||= args.state.total_enemies.map do
    if rand <= 0.025
      ChasingEnemySprite.new(args.outputs)
    elsif rand <= 0.1
      EnemySprite.new(args.outputs)
    else
      SlowEnemySprite.new(args.outputs)
    end
  end
end

def reset(args)
  args.outputs.static_sprites.clear
  args.state.player = nil
  args.state.enemies = nil
  args.state.food = nil
  args.state.star = nil
  args.state.total_enemies = 20
  # args.state.next_food = nil
  screams = %w[scream1.wav]
  args.outputs.sounds << "sounds/#{screams.sample}"
  args.state.high_score = args.state.score if args.state.score > args.state.high_score
  args.state.score = 0
  args.state.homer_available = true
  args.state.reset_count = args.tick_count + 180
  args.state.next_enemy = args.tick_count + 1000
  args.state.next_homer ||= args.tick_count + 1000
end

def check_player_collission(args)
  collided = false
  args.state.enemies.each do |enemy|
    if enemy.rect.intersect_rect?(args.state.player.rect)
      collided = enemy
      # puts "wrecked #{args.state.player.rect} #{enemy.rect}"
    end
  end
  collided
end

def check_enemy_collissions(enemies)
  collided_enemies = []
  enemies.each do |enemy|
    next if collided_enemies.include?(enemy)
    next if enemy.x < 0 || enemy.x > 1280
    next if enemy.y < 0 || enemy.y > 760

    enemies.each do |check|
      next if enemy == check
      enemy.register_collision -= 1 if enemy.register_collision >= 1
      if enemy.rect.intersect_rect? check.rect
        collided_enemies << check if enemy.register_collision < 1
        enemy.register_collision = 30
      end
    end
  end
  collided_enemies
end

def check_bounds(args)
  args.state.player.x >= 1300 || args.state.player.x <= -20 ||
  args.state.player.y >= 740 || args.state.player.y <= -20
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
    enemy.set_angle(args.state.tick_count, args.state.player)
  end
end
