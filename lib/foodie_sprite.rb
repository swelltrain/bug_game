class FoodieSprite
  attr_sprite
  attr_accessor :speed_xy, :speed_up_down, :previous_key_xy, :previous_key_up_down
  attr_accessor :x, :y, :w, :h, :angle
  attr_accessor :movement_probability, :rotation, :rotation_speed, :register_collision

  # KEYS = %w[right left up down]

  def initialize(outputs)
    @x = rand * 900
    @y = (rand * 200) + 400
    @w = 32 # size
    @h = 32
    @speed_xy = 0
    @speed_up_down = 0
    @path = 'sprites/buggy_attack.png'
    @previous_key_xy = nil
    @previous_key_up_down = nil
    # @weighted_keys = 10.map { KEYS.sample }
    @rotation = [1, -1].sample
    @rotation_speed = 360
    @register_collision = 0
    outputs.static_sprites << self
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

  def calculate_speed(simulated_key)
    multiplier = 1
    if simulated_key == "right"
      @speed_xy += 0.06 * multiplier unless @speed_xy > 5
      @previous_key_xy = "right"
    elsif simulated_key == "left"
      @speed_xy -= 0.06 * multiplier unless (@speed_xy * -1) > 5
      @previous_key_xy = "left"
    elsif simulated_key == "up"
      @speed_up_down += 0.03 * multiplier unless @speed_up_down > 5
      @previous_key_up_down = "up"
    elsif simulated_key == "down"
      @speed_up_down -= 0.03 * multiplier unless (@speed_up_down * -1) > 5
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
    simulated_key = weighted_keys.sample

    calculate_speed(simulated_key)
  end

  # def rect
  #   [@x, @y, @w / 2, @h / 2]
  # end

  # def x_y
  #   [@x, @y]
  # end
end
