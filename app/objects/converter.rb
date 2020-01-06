class Converter
  def self.convert(object, options)
    if object.is_a?(BigDecimal)
      object.truncate(2).to_f
    else fail
    end
  end
end