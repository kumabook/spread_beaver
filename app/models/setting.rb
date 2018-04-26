# frozen_string_literal: true
class Setting

  def self.load
    path = "#{Rails.root}/config/settings.yml"
    YAML.load(ERB.new(IO.read(path)).result).each do |name, value|
      define_class_method(name, value)
    end
  end

  def self.define_class_method(name, value)
    self.extend Module.new {
      define_method name.to_sym do
        value
      end
    }
  end

  load
end
