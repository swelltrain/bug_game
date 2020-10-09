class ChasingEnemySprite < BaseEnemySprite
  def initialize(outputs)
    @x = STARTING_X.sample
    @y = STARTING_Y.sample
    @w = 32 # size
    @h = 32
    @speed_xy = 0
    @speed_up_down = 0
    @speed_multiplier = (20..30).to_a.sample
    @speed_max = [2, 2.7, 2.9, 3.1,3.1, 3.1, 3.2, 3.5, 3.7, 3.9,4].sample * [0.1, 0.3, 0.9, 1.0,1.0,1.0,1.0,1.0, 2].sample

    @path = ['sprites/faster.png'].sample
    @previous_key_xy = nil
    @previous_key_up_down = nil
    @weighted_keys = 10.map { KEYS.sample }
    @rotation = [1, -1].sample
    @rotation_speed = 360
    @register_collision = 0
    @lunging = 0
    # @avoidence_circle = [180, 240].sample
  end

  def avoidence_circle
    [20, 60, 180, 240].sample
  end
  def set_angle(tick_count, player)
    _y = player.y - @y
    _x = player.x - @x
    _angle = Math.atan2(_y,_x)
    self.angle = _angle * (180/Math::PI)
  end

  def calculate_speed(simulated_key)
    multiplier =  @speed_multiplier
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

  def determine_move(args)
    simulated_key ||= off_screen?
    simulated_key ||= near_edge?
    simulated_key ||= near_enemy?(closest_other_entity(args.state.enemies))
    simulated_key ||= near_player?(args.state.player)

    calculate_speed(simulated_key)
    updated_weighted_keys(simulated_key) unless near_edge?
  end

  def near_player?(entity)
    @run_away = false
    possibilities = []

    distances = {
      "x" => entity.x - @x,
      "y" => entity.y - @y
    }
    close = 0
    distances.values.map(&:abs).each { |v| close += v }
    # return nil unless close < 200

    @run_away = true if close < avoidence_circle && entity.attitude != "run"

    @weighted_keys = 10.map { KEYS.sample }
    if @run_away
      possibilities << ((entity.x >= @x) ? "left" : "right")
      possibilities << ((entity.y >= @y) ? "down" : "up")
    else
      possibilities << ((entity.x >= @x) ? "right" : "left")
      possibilities << ((entity.y >= @y) ? "up" : "down")
    end

    possibilities.sample
  end
end
