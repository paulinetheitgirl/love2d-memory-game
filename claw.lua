require "util"

Claw = {
    x = 0,
    y = 0,
    width = 32,
    height = 32,
    is_moving_right = false,
    has_moved_right = false,
    is_capturing = false
}
    function Claw:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
    end
 
    function Claw:move_right(step, loop)
      if self.is_moving_right
      then
        if loop
        then
          self.x = math.min(self.x + step, love.graphics.getWidth() + self.width)
          self.x = (self.x >= love.graphics.getWidth() + self.width and -10) or self.x
        else
          self.x = math.min(self.x + step, love.graphics.getWidth() - self.width)
        end
      end
    end

    function Claw:move_down(step, stop_at_y)
      if self.is_capturing
      then
        self.y = math.min(self.y + step, stop_at_y)
      end
    end

    function Claw:move_return(step)
      if self.y > 0
      then
        self.y = math.max(self.y + step, 0)
      elseif self.x > 0
      then
        self.x = math.max(self.x + step, 10)
      end
    end

    function Claw:check_capture_prize(prize_images)
      local captured = 0
      for i, prize in ipairs(prize_images) do
        if (check_collision(self.x + (self.width / 4),
          self.y + (self.height * 3 / 4),
          self.width / 4,
          self.height / 4,
          prize.x + (prize.drawable:getWidth() / 4),
          prize.y,
          prize.drawable:getWidth() / 3,
          prize.drawable:getHeight() / 2))
        then
          prize.selected = true
          captured = i
          break
        end
      end
      return captured
    end