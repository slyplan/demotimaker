require 'RMagick'

class Demotimaker

  include Magick
  
  CONFIG = {:max_width => 500, :max_height => 400, :border => 40, :textarea => 100 }

  def initialize(image, title = "", text = "")
    @image = Image.read(image).first
    width_prop = CONFIG[:max_width].to_f / @image.columns.to_f
    height_prop = CONFIG[:max_height].to_f / @image.rows.to_f
    coef = width_prop > height_prop ? width_prop : height_prop
    @image.resize!(coef)
    
    @title = title
    @text  = text
    @demotivator = nil
  end

  def new?
    @demotivator.nil?
  end

  def display
    @demotivator.display
  end

  def generate
    background = Image.new(@image.columns + CONFIG[:border] * 2, @image.rows + CONFIG[:border] * 2 + CONFIG[:textarea]) { self.background_color = 'black'}
    composition = background.composite(@image, CONFIG[:border], CONFIG[:border], OverCompositeOp)
    
  end
end
