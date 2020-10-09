
class EnemySprite < BaseEnemySprite
  def initialize(outputs)
    @x = STARTING_X.sample
    @y = STARTING_Y.sample
    @w = 32 # size
    @h = 32
    @speed_xy = 0
    @speed_up_down = 0
    @speed_multiplier = (20..30).to_a.sample
    @speed_max = [2, 2.7, 2.9, 3.1,3.1, 3.1, 3.2, 3.5, 3.7, 3.9,4].sample * [0.1, 0.3, 0.9, 1.0,1.0,1.0,1.0,1.0, 2].sample

    @path = ['sprites/fast.png'].sample
    @previous_key_xy = nil
    @previous_key_up_down = nil
    @weighted_keys = 10.map { KEYS.sample }
    @rotation = [1, -1].sample
    @rotation_speed = 360
    @register_collision = 0
    @lunging = 0
    @avoidence_circle = [20, 40, 80, 200].sample
    @lunging_circle = [80, 200, 300].sample
  end


  def set_angle(tick_count, player)
    if lunging > 0
      _y = player.y - @y
      _x = player.x - @x
      _angle = Math.atan2(_y,_x)
      self.angle = _angle * (180/Math::PI)
    else
      self.angle = (tick_count % rotation_speed) * rotation
    end
  end

  def near_enemy_max_multiplier
    12
  end
end
