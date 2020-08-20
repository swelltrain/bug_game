class Player
  attr_sprite
  attr_accessor :speed_xy, :speed_up_down, :previous_key_xy, :previous_key_up_down
  attr_accessor :x, :y, :w, :h, :attitude, :r, :g, :b, :a, :path, :attack_for

  def initialize(outputs)
    @x = rand * 1260
    @y = (rand * 200)
    @w = 32 # size
    @h = 32
    # @r = 255
    # @g = 0
    # @b = 0
    @a = 255
    @speed_xy = 0
    @speed_up_down = 0
    @path = 'sprites/buggy.png'
    @previous_key_xy = nil
    @previous_key_up_down = nil
    @attitude = "run"
    @attack_for = 0
    @mute_running_out_of_attack = false
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

  def calculate_speed(key_held)
    if key_held.right
      @speed_xy += 0.7 unless @speed_xy > 4
      @previous_key_xy = "right"
    elsif key_held.left
      @speed_xy -= 0.7 unless (@speed_xy * -1) > 4
      @previous_key_xy = "left"
    elsif key_held.up
      @speed_up_down += 0.9 unless @speed_up_down > 4
      @previous_key_up_down = "up"
    elsif key_held.down
      @speed_up_down -= 0.9 unless (@speed_up_down * -1) > 4
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

  def decay_attack
    @attack_for -= 1 if @attack_for > 0
  end

  def run!
    @attitude = "run"
    @path = "sprites/buggy.png"
  end

  def attack!
    @attack_for = 800
    @attitude = "attack"
    @mute_running_out_of_attack = false
    @path = "sprites/buggy_attack.png"
  end

  def running_out_of_attack?
    return false if @mute_running_out_of_attack

    @attack_for < 100 && (@mute_running_out_of_attack = true)
  end

  def rect
    [@x, @y, @w / 2, @h / 2]
  end

  def x_y
    [@x, @y]
  end
end