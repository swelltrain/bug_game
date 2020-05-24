class Player
  attr_sprite
  attr_accessor :speed_xy, :speed_up_down, :previous_key_xy, :previous_key_up_down
  attr_accessor :x, :y, :w, :h

  def initialize(outputs)
    @x = rand * 1260
    @y = rand * 700
    @w = 32 # size
    @h = 32
    @speed_xy = 0
    @speed_up_down = 0
    @path = 'sprites/buggy.png'
    @previous_key_xy = nil
    @previous_key_up_down = nil
    outputs.static_sprites << self
  end

  def calculate_speed(key_held)
    if key_held.right
      @speed_xy += 0.5 unless @speed_xy > 10
      @previous_key_xy = "right"
    elsif key_held.left
      @speed_xy -= 0.5 unless (@speed_xy * -1) > 10
      @previous_key_xy = "left"
    elsif key_held.up
      @speed_up_down += 0.5 unless @speed_up_down > 10
      @previous_key_up_down = "up"
    elsif key_held.down
      @speed_up_down -= 0.5 unless (@speed_up_down * -1) > 10
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
end
