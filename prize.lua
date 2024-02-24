Prize = {
    display_index = 0,
    selected = false,
    x = 0,
    y = 0
}
    
-- same as Prize.new = function( Prize, o )
    function Prize:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
    end

    function Prize:move_return (step, dimension)
        self[dimension] = math.max(self[dimension] + step, 0)
    end
