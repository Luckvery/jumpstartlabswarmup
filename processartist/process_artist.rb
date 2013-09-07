require 'ruby-processing'

class ProcessArtist < Processing::App

  def setup
    ellipse_mode CENTER
    rect_mode CENTER
    @scale_value = 36
    background(rand(256),rand(256),rand(256))
  end

  def draw
   if mouse_pressed?
    stroke(rand(256))
     
     ellipse(mouse_x,mouse_y, @scale_value, @scale_value);
   end
  end

  def get_colors(rgb_values ="0,0,0")
    values = rgb_values.split(",")
    color_keys = [:red, :green, :blue]
    hash = {}
    color_keys.size.times { |i| hash[ color_keys[i] ] = values[i].to_i }
    hash
  end

  def valid_rgb?(rbg_string)
    result = true
    if (rbg_string.length < 6) 
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
      cols = get_colors(command)
      puts "Red: #{cols[:red]} | green: #{cols[:green]} | blue: #{cols[:blue]}"
      background(cols[:red],cols[:green],cols[:blue])
      puts "Changed Background color"
    else
      error
    end
  end

  def change_fill(command)
    if valid_rgb?(command)
      cols = get_colors(command)
      fill(cols[:red],cols[:green],cols[:blue])
      puts "Changed fill color"
    else
      error
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

  def error
    puts "Invalid Command"
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
        when "c"  then change_background("0,0,0")
        when "f"  then change_fill(@queue)
        when "+"  then increase_brush_size
        when "-"  then decrease_brush_size
        else
        
           error
      end
      @queue = ""
    end
  end
 end

ProcessArtist.new(:width => 400, :height => 400, 
                  :title => "ProcessArtist",:full_screen => false)
