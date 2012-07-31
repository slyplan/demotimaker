require 'RMagick'

class Demotimaker

  include Magick
  
  CONFIG = {:max_width => 500, :max_height => 400, :border => 40, :textarea => 100, :title_pointsize => 64, :text_pointsize => 24}

  def initialize(image, title = "", text = "")
    @image = Image.read(image).first
    width_prop = CONFIG[:max_width].to_f / @image.columns.to_f
    height_prop = CONFIG[:max_height].to_f / @image.rows.to_f
    coef = width_prop > height_prop ? width_prop : height_prop
    @image.resize!(coef)

    @full_width = @image.columns + CONFIG[:border] * 2
    @full_height = @image.rows + CONFIG[:border] * 2 + CONFIG[:textarea]
    
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
    background = Image.new(@full_width, @full_height) { self.background_color = 'black'}
    composition = background.composite(@image, CONFIG[:border], CONFIG[:border], OverCompositeOp)

    title_draw = Draw.new
    composition = composition.annotate(title_draw, 0, 0, @full_width / 2, @image.rows + CONFIG[:border] * 2 + CONFIG[:title_pointsize] / 2, @title) {
      self.font = File.join(File.dirname('__FILE__'), 'fonts', 'times.ttf')
      self.fill = 'white'
      self.pointsize = CONFIG[:title_pointsize]
      self.align = CenterAlign
    }

    composition = composition.annotate(title_draw, 0, 0, @full_width / 2, @image.rows + CONFIG[:border] * 2 + CONFIG[:title_pointsize] + CONFIG[:text_pointsize] / 2, @text) {
      self.font = File.join(File.dirname('__FILE__'), 'fonts', 'times.ttf')
      self.fill = 'white'
      self.pointsize = CONFIG[:text_pointsize]
      self.align = CenterAlign
    }


    @demotivator = composition
  end
end
