class Player
  attr_sprite
  attr_accessor :speed_xy, :speed_up_down,
    :previous_key_xy, :previous_key_up_down, :hit
  attr_accessor :x, :y, :w, :h, :attitude,
    :r, :g, :b, :a, :path, :attack_for, :health, :has_homer

  def initialize(outputs)
    @x = [100,300,500,700,900,1100].sample
    @y = [100,200,300,400,500,600].sample
    @w = 32 # size
    @h = 32
    # @r = 255
    # @g = 0
    # @b = 0
    @a = 255

    @previous_key_xy = ["left", "right"].sample
    @previous_key_up_down = ["up", "down"].sample
    @speed_xy = 1
    @speed_up_down = 1
    @path = 'sprites/buggy.png'
    @attitude = "run"
    @attack_for = 0
    @mute_running_out_of_attack = false
    @health = 100
    @hit = 0
    @has_homer = false
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

  def decrement_hit
    return if @hit == 0

    @hit -= 1
  end

  def max_speed_xy
    @attitude == "run" ? 4 : 5
  end

  def max_speed_up_down
    @attitude == "run" ? 3 : 4
  end

  def calculate_speed(key_held)
    # return if @hit > 0

    if key_held.right || key_held.l
      @speed_xy += 0.7 unless @speed_xy > max_speed_xy
      @previous_key_xy = "right"
    elsif key_held.left || key_held.j
      @speed_xy -= 0.7 unless (@speed_xy * -1) > max_speed_xy
      @previous_key_xy = "left"
    elsif key_held.up || key_held.w || key_held.i
      @speed_up_down += 0.9 unless @speed_up_down > max_speed_up_down
      @previous_key_up_down = "up"
    elsif key_held.down || key_held.s || key_held.k
      @speed_up_down -= 0.9 unless (@speed_up_down * -1) > max_speed_up_down
      @previous_key_up_down = "down"
    end
  end

  def move!
    if @previous_key_xy == "right"
      @x += @speed_xy #unless @x >= 1200
    end
    if @previous_key_xy == "left"
      @x += @speed_xy #unless @x <= -30
    end

    if @previous_key_up_down == "up"
      @y += @speed_up_down #unless @y >= 720
    end
    if @previous_key_up_down == "down"
      @y += @speed_up_down #unless @y <= -30
    end
  end

  def decrement_health(amount)
    @health -= amount
    @health = 0 if @health < 0
  end

  def increment_health(amount)
    @health += amount
    @health = 100 if @health > 100
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
