module Coffee
  class Drink
    attr_accessor :name, :size

    def initialize(name, size=0)
      @name, @size = name.capitalize, size.to_i
    end

    # @return Integer OZ
    def caffeine
      size * caffeine_per_oz
    end

    # @return Integer OZ
    def caffeine_per_oz
      from_yaml['caffeine']
    end

    def self.all
      @all ||= YAML.load_file(File.expand_path('../../coffee.yml', __FILE__)).map{|d| new(d['name'])}
    end

    private

    def yaml
      @yaml ||= YAML.load_file(File.expand_path('../../coffee.yml', __FILE__))
    end

    def from_yaml
      yaml.select{|d| d['name'] == name}.first
    end
  end
end
