class SlowEnemySprite
  attr_sprite
  attr_accessor :speed_xy, :speed_up_down, :previous_key_xy, :previous_key_up_down
  attr_accessor :x, :y, :w, :h, :angle
  attr_accessor :movement_probability, :rotation, :rotation_speed, :register_collision, :lunging, :injured

  KEYS = %w[right left up down]

  def initialize(outputs)
    @x = rand * 1260
    @y = (rand * 200) + 500
    @w = 32 # size
    @h = 32
    @speed_xy = 0
    @speed_up_down = 0
    @speed_multiplier = (5..20).to_a.sample
    @speed_max = [1,2.2, 2.5, 2.5, 2.9 ,3,3.2].sample * [0.1, 0.3, 0.6, 1].sample

    @path = 'sprites/squishy.png'
    @previous_key_xy = nil
    @previous_key_up_down = nil
    @weighted_keys = 10.map { KEYS.sample }
    @rotation = [1, -1].sample
    @rotation_speed = 360
    @register_collision = 0
    @lunging = 0

    puts "speed max #{@speed_max}"
  end

  def serialize
    {}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def decrement_speed_max
    return if @speed_max == 0
    @speed_max -= 1
  end

  def set_angle(tick_count, player)
    self.angle = (tick_count % rotation_speed) * rotation
  end

  def calculate_speed(simulated_key)
    multiplier = @near_player ? @speed_multiplier : nil
    multiplier ||= @near_enemy ? 7 : nil
    multiplier ||= @near_edge ? 4 : 1
    if simulated_key == "right"
      @speed_xy += 0.06 * multiplier unless @speed_xy > (@speed_max + @lunging)
      @previous_key_xy = "right"
    elsif simulated_key == "left"
      @speed_xy -= 0.06 * multiplier unless (@speed_xy * -1) > (@speed_max + @lunging)
      @previous_key_xy = "left"
    elsif simulated_key == "up"
      @speed_up_down += 0.03 * multiplier unless @speed_up_down > (@speed_max + @lunging)
      @previous_key_up_down = "up"
    elsif simulated_key == "down"
      @speed_up_down -= 0.03 * multiplier unless (@speed_up_down * -1) > (@speed_max + @lunging)
      @previous_key_up_down = "down"
    end

  end

  def move!
    if @previous_key_xy == "right"
      @x += @speed_xy unless @x >= 1200
    end
    if @previous_key_xy == "left"
      @x += @speed_xy unless @x <= -30
    end

    if @previous_key_up_down == "up"
      @y += @speed_up_down unless @y >= 720
    end
    if @previous_key_up_down == "down"
      @y += @speed_up_down unless @y <= -30
    end
  end

  def determine_move(args)
    simulated_key = near_edge?
    simulated_key ||= near_player?(args.state.player)
    simulated_key ||= near_enemy?(closest_other_entity(args.state.enemies))
    simulated_key ||= weighted_keys.sample

    calculate_speed(simulated_key)
    updated_weighted_keys(simulated_key) unless near_edge?
  end

  def near_edge?
    @near_edge = false
    # notice they are opposite
    stuff_to_avoid = {
      "left" => 1400 - @x,
      "right" => 100 + @x,
      "down" => 750 - @y,
      "up" => 100 + @y
    }
    # return nil unless one of the edges is close

    return nil unless stuff_to_avoid.detect { |_k, v| v < 200 }
    closest = stuff_to_avoid.values.sort.first
    simulated_key = stuff_to_avoid.detect { |_k, v| v == closest }
    @near_edge = true
    @weighted_keys = 10.map { KEYS.sample }
    chosen = simulated_key[0]
    chosen
  end

  def near_player?(entity)
    @near_player = false

    distances = {
      "x" => entity.x - @x,
      "y" => entity.y - @y
    }
    close = 0
    distances.values.map(&:abs).each { |v| close += v }
    return nil unless close < 200
    if entity.attitude == "run"
      closest = distances.values.map(&:abs).sort.last
    else
      closest = distances.values.map(&:abs).sort.first
    end
    @near_player = true unless @injured
    nearby = distances.detect { |_k,v| v == closest }[0]
    @weighted_keys = 10.map { KEYS.sample }
    if nearby == "x"
      if entity.attitude == "run"
        distances["x"] > 0 ? "right" : "left"
      else
        distances["x"] > 0 ? "left" : "right"
      end
    else
      if entity.attitude == "run"
        distances["y"] > 0 ? "up" : "down"
      else
        distances["y"] > 0 ? "down" : "up"
      end
    end
  end

  def near_enemy?(entity)
    @near_enemy = false
    return if entity == nil

    distances = {
      "x" => entity.x - @x,
      "y" => entity.y - @y
    }
    close = 0
    distances.values.map(&:abs).each { |v| close += v }
    return nil unless close < 200
    closest = distances.values.map(&:abs).sort.first
    @near_enemy = true
    nearby = distances.detect { |_k,v| v == closest }[0]
    # @weighted_keys = 10.map { KEYS.sample }
    if nearby == "x"
      distances["x"] > 0 ? "left" : "right"
    else
      distances["y"] > 0 ? "down" : "up"
    end
  end

  def weighted_keys
    @weighted_keys + KEYS
  end

  def updated_weighted_keys(key)
    return if [nil, nil, nil, true].sample

    if key == "right"
      index = @weighted_keys.index("left")
      @weighted_keys[index] = key if index
    elsif key == "left"
      index = @weighted_keys.index("right")
      @weighted_keys[index] = key if index
    elsif key == "up"
      index = @weighted_keys.index("down")
      @weighted_keys[index] = key if index
    elsif key == "down"
      index = @weighted_keys.index("up")
      @weighted_keys[index] = key if index
    end
  end

  def closest_other_entity(enemies)
    closest_distance = 200
    enemy_first_within_distance = nil
    enemies.each do |enemy|
      next if enemy == self
      distance = (enemy.x - @x).abs + (enemy.y - @y).abs
      enemy_first_within_distance = enemy if distance < closest_distance
      next if enemy_first_within_distance
    end
    enemy_first_within_distance
  end

  def rect
    [@x, @y, @w / 2, @h / 2]
  end

  def x_y
    [@x, @y]
  end
end
