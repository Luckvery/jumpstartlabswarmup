require 'ruby-processing'

class ProcessArtist < Processing::App

  def setup
    ellipse_mode CENTER
    rect_mode CENTER
    @scale_value = 36
    @angle = 0
    @brush=0
    init_brush_types
    init_background_color
  end

  def init_background_color
    @bg_color =color(rand(256),rand(256),rand(256))
    background(@bg_color)
  end
  
  def init_brush_types
    @brush_types = ["Circle", "Tall Oval", "Wide Oval", "Clover", "Funky",
                    "Square", "Wide Rectangle", "Tall Rectangle", "Plus"]
  end
                    

  def draw
   if mouse_pressed?
    stroke(rand(256))
    draw_shape
   end
  end

  def draw_shape
   success = true
   case @brush_types[@brush]
     when "Circle"    then
      ellipse(mouse_x,mouse_y, @scale_value, @scale_value)
     when "Tall Oval"       then 
      ellipse(mouse_x,mouse_y, @scale_value, @scale_value *2)
     when "Wide Oval"       then 
      ellipse(mouse_x,mouse_y, @scale_value*2, @scale_value)
     when "Clover"          then
      clover(mouse_x,mouse_y)
     when "Funky"           then
      funky(mouse_x,mouse_y)
     when "Square"           then 
      rect(mouse_x,mouse_y, @scale_value, @scale_value)
     when "Wide Rectangle"  then 
      rect(mouse_x,mouse_y, @scale_value*4, @scale_value)
     when "Tall Rectangle"  then 
      rect(mouse_x,mouse_y, @scale_value, @scale_value*4)
     when "Plus"            then 
      plus(mouse_x,mouse_y)
   end
  end

  def clover(x,y)
    offset = @scale_value/2
    ellipse(mouse_x+offset,mouse_y, @scale_value, @scale_value)
    ellipse(mouse_x-offset,mouse_y, @scale_value, @scale_value)
    ellipse(mouse_x,mouse_y+offset, @scale_value, @scale_value)
    ellipse(mouse_x,mouse_y-offset, @scale_value, @scale_value)
  end

  def plus(x,y)
    line(x-@scale_value, y+@scale_value, x+@scale_value, y-@scale_value)
    line(x+@scale_value, y+@scale_value, x-@scale_value, y-@scale_value)
  end

  def funky(x,y)
    px = py = @scale_value 
    @angle += 5
    val = cos(radians(@angle)) * 12.0;
     
    (0..360).step(75) do |a|
      xoff = cos(radians(a)) * val;
      yoff = sin(radians(a)) * val;
      fill(0);
      ellipse(x + xoff, y + yoff, val, val);
    end
    fill(255);
    ellipse(x, y, 2, 2);
  end

  def get_colors(rgb_values ="0,0,0")
    color_values = rgb_values.split(",")
    color(color_values[0].to_i, color_values[1].to_i, color_values[2].to_i)
  end

  def valid_rgb?(rbg_string)
    result = true
    if (rbg_string.length < 5)
      puts rbg_string + " < 6"
     result = false
    else
      rbg_string.split(",").each do |color|
       result = false unless color.to_i.between?(0,255) 
      end
    end
    result
  end

  def change_background(command)    
    if valid_rgb?(command)
     @bg_color = get_colors(command)
      background(@bg_color)
      puts "Changed Background color"
    else
      error "Background Color"
    end
  end

  def change_fill(command)
    if valid_rgb?(command)
      @bg_color = get_colors(command)
      fill(@bg_color)
      puts "Changed fill color"
    else
      error "Fill Color"
    end
  end 

  def change_brush(command)
    #only a zero if not a number and s0 is not an option
    num = command.to_i

    if num == 0 || num > 9
      error "brush"
    else
     @brush = num-1
     puts "Changed brush to: " +  @brush_types[@brush]
    end
  end
 
  def increase_brush_size
    @scale_value = @scale_value + 1.0
    scale(@scale_value)
    puts "Increased the size of the brush by one pixel(#{@scale_value})"
  end

  def decrease_brush_size  
    if @scale_value != 0
     @scale_value = @scale_value - 1.0
     scale(@scale_value)
     puts "Decreased the size of the brush by one pixel(#{@scale_value})"
    else
     puts "Can not decrease size of brush beyond zero"
    end
  end

  def error(issue="Command")
    puts "Invalid " + issue
  end 

  def key_pressed

     warn "A key was pressed! #{key.inspect}"

    if @queue.nil?
      @queue = ""
    end 

    if !key.is_a? String 
      error
    elsif key != "\n"
     @queue = @queue + key  
    
    else 
      command = @queue[0..0]
      @queue[0,1] = ''
      case command
        when "b"  then change_background(@queue) 
        when "c"  then background(@bg_color)
        when "f"  then change_fill(@queue)
        when "+"  then increase_brush_size
        when "-"  then decrease_brush_size
        when "s"  then change_brush(@queue)
        else
           error command
      end
      @queue = ""
    end
  end
 end

ProcessArtist.new(:width => 400, :height => 400, 
                  :title => "ProcessArtist",:full_screen => false)
