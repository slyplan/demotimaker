require 'RMagick'

class Demotimaker

  include Magick
  
  CONFIG = {
    :max_width => 500,
    :max_height => 400,
    :border => 40,
    :textarea => 100,
    :title_pointsize => 64,
    :text_pointsize => 24,
    :white_line => 3,
    :black_line => 3,
    :signature_lenght => 120,
    :signature_size => 12
  }

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

  #TODO
  #Too large mathod make it smaller
  def generate(signature = nil)
    background = Image.new(@full_width, @full_height) { self.background_color = 'black'}
    black_line_width = CONFIG[:black_line] * 2
    white_line_width = CONFIG[:white_line] * 2 + black_line_width
    white_line = Image.new(@image.columns + white_line_width, @image.rows + white_line_width) { self.background_color = 'white'}
    black_line = Image.new(@image.columns + black_line_width, @image.rows + black_line_width) { self.background_color = 'black'}
    
    background = background.composite(white_line, CONFIG[:border] - CONFIG[:black_line] - CONFIG[:white_line],  CONFIG[:border] - CONFIG[:black_line] - CONFIG[:white_line], OverCompositeOp)
    background = background.composite(black_line, CONFIG[:border] - CONFIG[:white_line],  CONFIG[:border] - CONFIG[:white_line], OverCompositeOp)

    composition = background.composite(@image, CONFIG[:border], CONFIG[:border], OverCompositeOp)

    title_draw = Draw.new
    composition = composition.annotate(title_draw, 0, 0, @full_width / 2, @image.rows + CONFIG[:border] * 2 + CONFIG[:title_pointsize] / 2, @title) {
      self.font = File.join(File.dirname('__FILE__'), 'fonts', 'times.ttf')
      self.fill = 'white'
      self.pointsize = CONFIG[:title_pointsize]
      self.kerning = 1
      self.align = CenterAlign
    }

    composition = composition.annotate(title_draw, 0, 0, @full_width / 2, @image.rows + CONFIG[:border] * 2 + CONFIG[:title_pointsize], @text) {
      self.font = File.join(File.dirname('__FILE__'), 'fonts', 'times.ttf')
      self.fill = 'white'
      self.pointsize = CONFIG[:text_pointsize]
      self.kerning = 1
      self.align = CenterAlign
    }

    composition["demotivator-generator"] = "slyplan"
    composition["demotivator-generator-version"] = "0.1"
    composition["demotivator-title"] = @title
    composition["demotivator-text"] = @text

    @demotivator = composition
    add_signature(signature) unless signature.nil?
  end

  #TODO add dynamycal generation of signature_lenght
  def add_signature(signature)
    return false if new?
    signature_draw = Draw.new
    signature_image = Image.new(CONFIG[:signature_lenght], CONFIG[:signature_size] + 2) { self.background_color = 'black'}
    signature_image = signature_image.annotate(signature_draw, 0, 0, 0, 0, signature) {
      self.fill = 'white'
      self.pointsize = CONFIG[:signature_size]
      self.gravity = CenterGravity
    }
    @demotivator = @demotivator.composite(signature_image, @full_width - CONFIG[:signature_lenght] - CONFIG[:border], @full_height - CONFIG[:border] - CONFIG[:textarea], OverCompositeOp)
    true
  end

  def save(file)
    generate if new?
    @demotivator.write(file)
  end
  
end
