
class SlowEnemySprite < BaseEnemySprite

  def initialize(outputs)
    @x = STARTING_X.sample
    @y = STARTING_Y.sample
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
    @avoidence_circle = [20, 40, 80, 200].sample
    @lunging_circle = [80, 120].sample
  end

  def set_angle(tick_count, player)
    self.angle = (tick_count % rotation_speed) * rotation
  end

  def near_enemy_max_multiplier
    7
  end
end
