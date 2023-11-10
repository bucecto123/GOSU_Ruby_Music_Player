require 'rubygems'
require 'gosu'
require_relative 'albums_function.rb'
require_relative 'input_functions.rb'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

ROOT_DIR = File.dirname(__FILE__) + '/'

puts ROOT_DIR
# Read a collection of albums that will be used by both class
file = File.new(ROOT_DIR + %q(music_list.txt), "r")
$albums = read_albums(file)
file.close()

# Music player
class MusicPlayerMain < Gosu::Window
	def initialize
	  super(600,800,false)
	  self.caption = "Music Player"
		@background = BOTTOM_COLOR
		@player = TOP_COLOR
		@track_font = Gosu::Font.new(15)
    @album_id = $select
    @album = $albums[@album_id]
    @track_id = 0
    @volume = 0.5
    @volume_on = true
    playTrack()
    @play_button = ArtWork.new(ROOT_DIR+'Music_player_components/play_button.png')
    @stop_button = ArtWork.new(ROOT_DIR+'Music_player_components/stop_button.png')
    @next_song_button = ArtWork.new(ROOT_DIR+'Music_player_components/next_song.png')
    @prev_song_button = ArtWork.new(ROOT_DIR+'Music_player_components/prev_song.png')
    @home_button = ArtWork.new(ROOT_DIR+'Music_player_components/home button.png')
    @heart_button_1 = ArtWork.new(ROOT_DIR+'Music_player_components/heart_icon_1.png')
    @heart_button_2 = ArtWork.new(ROOT_DIR+'Music_player_components/heart_icon_2.png')
    @loop_button_1 = ArtWork.new(ROOT_DIR+'Music_player_components/loop_button_1.png')
    @loop_button_2 = ArtWork.new(ROOT_DIR+'Music_player_components/loop_button_2.png')
    @shuffle_button_1 = ArtWork.new(ROOT_DIR+'Music_player_components/shuffle_button_1.png')
    @shuffle_button_2 = ArtWork.new(ROOT_DIR+'Music_player_components/shuffle_button_2.png')
    @volume_icon = ArtWork.new(ROOT_DIR + 'Music_player_components\volume.png')
    @no_volume_icon = ArtWork.new(ROOT_DIR + 'Music_player_components\no_volume.png')
    @page_num = 1
    @loop = false
    @shuffle = false
	end

  # Methods to play track
  # Takes a track index and an Album and plays the Track from the Album
  def playTrack()
    # complete the missing code
    @track = @album.tracks[@track_id]
    @location = ROOT_DIR + @track.location.chomp
    @song = Gosu::Song.new(@location)
    if !@volume_on
      @song.volume = 0
    else
      @song.volume = @volume
    end
    @song.play(false)
  end
  #  Auto play the next song when the current song ends
  def auto_play()
    if !@shulffle && !@loop 
      if Gosu::Song.current_song == nil
        if @track_id < @album.tracks.length
          @track_id += 1
        else
          if @album_id < $albums.length-1
            @album_id += 1
          else
            @album_id = 0 
          end
        @track_id = 0
        @album = $albums[@album_id]
      end
    elsif @shuffle
      old_track_id = @track_id
      while @track_id == old_track_id
        @track_id = rand(0, @album.tracks.length)
      end
    end
    playTrack()
    end
  end

  # Drawing methods
  # Draws the artwork on the screen for the running album
  def draw_track_and_album_name()
    @album_name = "Album:  " + $albums[@album_id].title.chomp + " by " + $albums[@album_id].artist.chomp
    @track_font.draw_text(@album_name, 177, 413, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
    start_track_num = 0 + (@page_num-1)*5
    end_track_num = start_track_num + 4
    for i in start_track_num..end_track_num
      name = @album.tracks[i].name.chomp rescue ""
      if i == @track_id and name != ""
        name += "  =>  Now playing"
      end
      case i % 5
      when 0
        @track_font.draw_text(name, 154, 437, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      when 1
        @track_font.draw_text(name, 154, 467, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      when 2
        @track_font.draw_text(name, 154, 497, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      when 3
        @track_font.draw_text(name, 154, 527, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      when 4
        @track_font.draw_text(name, 154, 557, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      end
    end
  end

  def draw_buttons()
    @home_button.bmp.draw(100-40, 650, ZOrder::UI)
    @prev_song_button.bmp.draw(200-40, 650, ZOrder::UI)
    @next_song_button.bmp.draw(400-40, 650, ZOrder::UI)

    if @track.like
      @heart_button_2.bmp.draw(500-40, 650, ZOrder::UI)
    else
      @heart_button_1.bmp.draw(500-40, 650, ZOrder::UI)
    end

    if @song.paused?
      @play_button.bmp.draw(300-40, 650, ZOrder::UI)
    else
      @stop_button.bmp.draw(300-40, 650, ZOrder::UI)
    end

    if !@loop
      @loop_button_1.bmp.draw(100 -40, 450, ZOrder::UI)
    else
      @loop_button_2.bmp.draw(100 -40, 450, ZOrder::UI)
    end
    
    if !@shuffle
      @shuffle_button_1.bmp.draw(500-40, 450, ZOrder::UI)
    else
      @shuffle_button_2.bmp.draw(500-40, 450, ZOrder::UI)
    end

    @track_font.draw_text("<<", 120 -40, 250, ZOrder::UI, 2.5, 2.5, Gosu::Color::BLUE)
    @track_font.draw_text(">>", 520-40, 250, ZOrder::UI, 2.5, 2.5, Gosu::Color::BLUE)
    
    if !@volume_on || @volume < 0.1
      @no_volume_icon.bmp.draw(110, 60, ZOrder::UI)
    else
      @volume_icon.bmp.draw(110, 60, ZOrder::UI)
    end

    draw_rect(200, 98, 200, 4, Gosu::Color::WHITE, ZOrder::UI )
    draw_rect(200, 98, 200*@volume, 4, Gosu::Color::BLACK, ZOrder::UI )
    @track_font.draw_text("+   -", 420, 82, ZOrder::UI, 2.5, 2.5, Gosu::Color::BLUE)
  end
 
  def draw_displaytrack()
    album_cover = ArtWork.new(ROOT_DIR + @album.cover)
    album_cover.bmp.draw(200,150,ZOrder::UI)
    @display_track_image = ArtWork.new(ROOT_DIR+'Music_player_components/displaytrack.bmp')
    @display_track_image.bmp.draw(143, 404, ZOrder::UI)
  end

	def draw_background
    Gosu.draw_rect(0,0,600,800, @background, ZOrder::BACKGROUND, mode=:default)
    Gosu.draw_rect(50, 50, 500, 700, @player, ZOrder::PLAYER, mode=:default)
  end

  def update
    if @turn_off == false
      auto_play()
    end
  end


	def draw()
		# Complete the missing code
		draw_background()
    draw_displaytrack()
    draw_buttons()
    draw_track_and_album_name()
	end
  # Keyboard & Mouse input
 	def needs_cursor?; true; end

  def area_clicked(mouse_x,mouse_y)
    if mouse_y > 600 && mouse_y < 700
      if mouse_x > 50 && mouse_x < 150
        return 1
      elsif mouse_x > 150 && mouse_x < 250
        return 2
      elsif mouse_x > 250 && mouse_x < 350
        return 3
      elsif mouse_x > 350 && mouse_x < 450
        return 4
      elsif mouse_x > 450 && mouse_x < 550
        return 5
      end
    elsif mouse_y > 400 && mouse_y < 500
      if mouse_x > 50 && mouse_x < 150
        return 6
      elsif mouse_x > 450 && mouse_x < 550
        return 7
      end
    elsif mouse_y > 200 && mouse_y < 300
      if mouse_x > 50 && mouse_x < 150
        return 8
      elsif mouse_x > 450 && mouse_x < 550
        return 9
      end
    elsif mouse_y > 50 && mouse_y < 150
      if mouse_x > 100 && mouse_x < 200
        return 10
      elsif mouse_x > 400 && mouse_x < 450
        return 11
      elsif mouse_x > 400 && mouse_x < 500
        return 12
      end
    end
  end

	def button_down(id)
    case id
    when Gosu::KbSpace
      if @song.playing?
        @song.pause
      elsif @song.paused?
        @song.play
      end
    when Gosu::KbM
      @volume_on = !@volume_on
      if @volume_on
        @song.volume = @volume
      else
        @song.volume = 0
       end
    when Gosu::KbDown
      if @volume > 0 && @volume_on
        @volume -= 0.1
        @song.volume = @volume
      end
    when Gosu::KbUp
      if @volume < 1 && @volume_on
        @volume += 0.1
        @song.volume = @volume
      end
    when Gosu::KbRight
      if @track_id < @album.tracks.length-1
        @track_id += 1
      else
        @track_id = 0
      end
      @page_num = @track_id/5 + 1
      playTrack()
    when Gosu::KbLeft
      if @track_id > 0
        @track_id -= 1
        else
        @track_id = @album.tracks.length - 1
      end 
      @page_num = @track_id/5 + 1
      playTrack()
    # Control by click  
    when Gosu::MsLeft
      event = area_clicked(mouse_x,mouse_y)
      case event
      when 1
        close
        @song.stop
        @turn_off = true
        HomeMain.new.show if __FILE__ == $0
      when 2
        if @track_id > 0
        @track_id -= 1
        else
        @track_id = @album.tracks.length - 1
        end 
        @page_num = @track_id/5 + 1
        playTrack()
      when 3
        if @song.playing?
          @song.pause
        elsif @song.paused?
          @song.play
        end
      when 4
        if @track_id < @album.tracks.length-1
          @track_id += 1
        else
          @track_id = 0
        end 
        @page_num = @track_id/5 + 1
        playTrack()
      when 5
        $albums[@album_id].tracks[@track_id].like = !$albums[@album_id].tracks[@track_id].like
        if $albums[@album_id].tracks[@track_id].like
          $albums[-1].tracks << @album.tracks[@track_id]
        else
         $albums[-1].tracks.delete(@album.tracks[@track_id])
        end
      when 6
        @loop = !@loop
        if @loop && @shuffle
          @shuffle = false
        end
      when 7
        @shuffle = !@shuffle
        if @loop && @shuffle
          @loop = false
        end
      when 8
        @track_id = 0
        if @album_id != 0
          @album_id -= 1
        else
          @album_id = $albums.length - 1
        end
        @album = $albums[@album_id]
        if @album.tracks == []
          @album_id -= 1
          @album = $albums[@album_id]
        end
        playTrack()
      when 9
        @track_id = 0
        if @album_id != $albums.length - 1
          @album_id += 1
        else
          @album_id = 0
        end
        @album = $albums[@album_id]
        if @album.tracks == []
          @album_id = 0
          @album = $albums[@album_id]
        end
        playTrack()
      when 10
        @volume_on = !@volume_on
        if @volume_on
          @song.volume = @volume
        else
          @song.volume = 0
        end
      when 11
        if @volume < 1 && @volume_on
          @volume += 0.1
          @song.volume = @volume
        end
      when 12
        if @volume > 0 && @volume_on
          @volume -= 0.1
          @song.volume = @volume
        end
      end
    end
  end
end

# Music player home
class HomeMain < Gosu::Window
	def initialize
	  super 600, 800
	  self.caption = "Music Player"
    @background = BOTTOM_COLOR
    @player = TOP_COLOR
    @track_font = Gosu::Font.new(16)
    @page_num = 1
    @max_page_num = ($albums.length.to_f/4).ceil
	end

  # Put in your code here to load albums and tracks
  # Draws the artwork on the screen for all the albums

  def draw_albums(page_num)
    # complete this code
    start_alb_num = 0 + (page_num-1)*4
    end_alb_num = 3 + start_alb_num
    x_cor = 10
    y_cor = 10
    for i in start_alb_num..end_alb_num
      if i < $albums.length && $albums[i].tracks != []
        @album_cover = ArtWork.new(ROOT_DIR+$albums[i].cover)
        @album_title = Gosu::Image.from_text(self, $albums[i].title, Gosu.default_font_name, 16)
        case i % 4
        when 0
          cover_x = 75
          cover_y = 125
          title_x = 175
          title_y = 350
        when 1
          cover_x = 325
          cover_y = 125
          title_x = 425
          title_y = 350
        when 2
          cover_x = 75
          cover_y = 375
          title_x = 175
          title_y = 600
        when 3
          cover_x = 325
          cover_y = 375
          title_x = 425
          title_y = 600
        end
      @album_cover.bmp.draw(cover_x, cover_y, ZOrder::UI)
      @album_title.draw_rot(title_x, title_y, ZOrder::UI)
      end
    end
  end

    # Detects if a 'mouse sensitive' area has been clicked on
    # i.e either an album or a track. returns true or false

  def area_clicked(mouse_x,mouse_y)
      # complete this code
    if mouse_y > 100 && mouse_y < 350
      if mouse_x > 50 && mouse_x < 300
        return 1
      elsif mouse_x > 300 && mouse_x < 550
        return 2
      end
    end

    if mouse_y > 350 && mouse_y < 600
      if mouse_x > 50 && mouse_x < 300
        return 3
      elsif mouse_x > 300 && mouse_x < 550
        return 4
      end
    end

    if mouse_y > 600 && mouse_y < 750
      if mouse_x > 50 && mouse_x < 250
        return 5
      elsif mouse_x > 300 && mouse_x < 550
        return 6
      end
    end
  end

    # Takes a String title and an Integer ypos    
    # You may want to use the following:
  def display_track(title, ypos)
      @track_font.draw(title, TrackLeftX, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
  end

  # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
  def draw_background
    Gosu.draw_rect(0,0,600,800, @background, ZOrder::BACKGROUND, mode=:default)
    Gosu.draw_rect(50, 50, 500, 700, @player, ZOrder::PLAYER, mode=:default)
  end
  
  def draw_button()
      @track_font.draw_text("All Albums", 220, 60, ZOrder::UI, 2.5, 2.5, Gosu::Color::BLUE)
      Gosu.draw_rect(220, 100, 160, 5, Gosu::Color::BLUE , ZOrder::UI, mode=:default)
      @track_font.draw_text("<<", 100, 675, ZOrder::UI, 2.5, 2.5, Gosu::Color::BLUE)
      @track_font.draw_text(">>", 450 , 675, ZOrder::UI, 2.5, 2.5, Gosu::Color::BLUE)
  end
 
  # Not used? Everything depends on mouse actions.

  def update
  end

  # Draws the album images and the track list for the selected album

  def draw
    # Complete the missing code
    draw_background()
    draw_albums(@page_num)
    draw_button
  end

  def needs_cursor?; true; end
  # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
  # you will learn about inheritance in the OOP unit - for now just accept that
  # these are available and filled with the latest x and y locations of the mouse click.

  def button_down(id)
    case id
      when Gosu::MsLeft
        # What should happen here?
        event = area_clicked(mouse_x, mouse_y)
        case event 
        when 1
          $select = 0 + (@page_num-1)*4
          if $select < $albums.length && $albums[$select].tracks != []
            close
            MusicPlayerMain.new.show if __FILE__ == $0
          end
        when 2
          $select = 1 + (@page_num-1)*4
          if $select < $albums.length && $albums[$select].tracks != []
            close
            MusicPlayerMain.new.show if __FILE__ == $0
          end
        when 3
          $select = 2 + (@page_num-1)*4
          if $select < $albums.length && $albums[$select].tracks != []
            close
            MusicPlayerMain.new.show if __FILE__ == $0
          end
        when 4
          $select = 3 + (@page_num-1)*4
          if $select < $albums.length && $albums[$select].tracks != []
            close
            MusicPlayerMain.new.show if __FILE__ == $0
          end
        when 5
          if @page_num > 1
            @page_num -= 1
          else
            @page_num = @max_page_num
          end
        when 6
          if @page_num < @max_page_num
            @page_num += 1
          else
            @page_num = 1
          end
        end
      end
  end
end
# Show is a method that loops through update and draw

HomeMain.new.show if __FILE__ == $0
