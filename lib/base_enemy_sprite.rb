class BaseEnemySprite
  attr_sprite
  attr_accessor :speed_xy, :speed_up_down, :previous_key_xy, :previous_key_up_down
  attr_accessor :movement_probability, :rotation, :rotation_speed,
                :register_collision, :lunging, :injured, :avoidence_circle, :lunging_circle

  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
                :tile_y, :tile_w, :tile_h, :flip_horizontally,
                :flip_vertically, :angle_anchor_x, :angle_anchor_y

  KEYS = %w[right left up down].freeze

  STARTING_X = [-240, -200, -180, -120, 1700, 1740, 1780, 1820].freeze
  STARTING_Y = [-240, -200, -180, -120, 900, 940, 980, 1020].freeze

  def primitive_marker
    :sprite
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

  def near_enemy_max_multiplier
    raise "must be implemented by child class"
  end

  def set_angle
    raise "must be implemented by child class"
  end

  def decrement_speed_max
    return if @speed_max == 0

    @speed_max -= 0.25
  end


  def calculate_speed(simulated_key)
    multiplier = @near_player ? @speed_multiplier : nil
    multiplier ||= @near_enemy ? near_enemy_max_multiplier : nil
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
    simulated_key = off_screen?
    simulated_key ||= near_edge?
    simulated_key ||= near_player?(args.state.player)
    simulated_key ||= near_enemy?(closest_other_entity(args.state.enemies))
    simulated_key ||= near_food?(args.state.food)
    simulated_key ||= weighted_keys.sample

    calculate_speed(simulated_key)
    # updated_weighted_keys(simulated_key) unless near_edge?
    updated_weighted_keys(simulated_key)
  end

  def off_screen?
    possibilities = []
    if @x > 1800
      possibilities << "left"
    elsif @x < -20
      possibilities << "right"
    end
    if @y > 780
      possibilities << "down"
    elsif @y < -20
      possibilities << "up"
    end
    possibilities.sample
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

    return nil unless stuff_to_avoid.detect { |_k, v| v < 20 }

    closest = stuff_to_avoid.values.sort.first
    simulated_key = stuff_to_avoid.detect { |_k, v| v == closest }
    @near_edge = true
    @weighted_keys = 10.map { KEYS.sample }
    chosen = simulated_key[0]
    chosen
  end

  def near_food?(food)
    @near_food = false
    return unless food

    diff_x = (food.x - @x).abs
    diff_y = (food.y - @y).abs
    # return if diff_x + diff_y < 80

    possibilities = []
    if @x >= food.x
      possibilities << "left"
    elsif @x <= food.x
      possibilities << "right"
    end
    if @y >= food.y
      possibilities << "down"
    elsif @y <= food.y
      possibilities << "up"
    end
    possibilities.sample
  end

  def near_player?(entity)
    @near_player = false

    distances = {
      "x" => entity.x - @x,
      "y" => entity.y - @y
    }
    close = 0
    distances.values.map(&:abs).each { |v| close += v }
    return nil unless close < lunging_circle
    if entity.attitude == "run"
      closest = distances.values.map(&:abs).sort.last
    else
      closest = distances.values.map(&:abs).sort.first
    end
    # @near_player = true unless @injured
    @near_player = true
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
    return nil unless close < avoidence_circle

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
      if distance < closest_distance
        enemy_first_within_distance = enemy
        closest_distance = distance
      end
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
