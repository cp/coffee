module Coffee
  class Consumption
    attr_accessor :drink

    def initialize(drink)
      @drink = drink
    end

    def save
      Keen.publish(:consumptions, {
        drink: { name: drink.name, size: drink.size.to_i },
        caffeine: drink.caffeine.to_i
      })
    end
  end
end
