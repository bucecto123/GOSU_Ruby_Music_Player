require_relative 'input_functions.rb'

module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end
  
$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

# Track definition
class Track
    attr_accessor :name, :location, :like
    
    def initialize (name, location)
        @name = name
        @location = location
        @like = false
    end
end

# Reads in and returns a single track from the given file
def read_track(music_file)
	new_track = Track.new(music_file.gets, music_file.gets)
end

# Returns an array of tracks read from the given file
def read_tracks(music_file)
	count = music_file.gets().to_i()
  	tracks = Array.new()
  	i = 0
	while i < count
		track = read_track(music_file)
		tracks << track
		i += 1
	end
	return tracks
end

# Takes a single track and prints it to the terminal
def print_track(track)
    puts(track.name)
  puts(track.location)
end

# Takes an array of tracks and prints them to the terminal
def print_tracks(tracks)
	# print all the tracks use: tracks[x] to access each track.
	puts "Track list:"
    i = 0
	while i < tracks.length
        puts "Track #{i}:"
		print_track(tracks[i])
		i+=1
	end
end

# Album definition
class Album
    attr_accessor :title, :artist, :genre, :tracks, :year, :cover
    
    def initialize (title, artist, year, genre, tracks, cover)
        @genre = genre
        @artist = artist
        @title = title
        @tracks = tracks
        @year = year
        @cover = cover
    end
end

# Reads in and returns a single album from the given file
def read_album(music_file)
    album_title = music_file.gets.chomp
    album_artist = music_file.gets.chomp
    album_year = music_file.gets.chomp
    album_genre = music_file.gets.to_i
    album_cover = music_file.gets.chomp
    album_tracks = read_tracks(music_file)
    album = Album.new(album_title, album_artist, album_year, album_genre, album_tracks, album_cover)
    return album
end

# Returns an array of albums read from the given file
def read_albums(music_file)
    i = music_file.gets.to_i
    albums = []
    while i > 0
        albums << read_album(music_file)
        i -= 1
    end
    return albums
end

# Takes a single album and prints it to the terminal along with all its tracks
def print_album(album)
    puts album.artist
    puts album.title
    puts('Genre is ' + album.genre.to_s)
    puts($genre_names[album.genre])
    print_tracks(album.tracks)
    puts "\n"
end

# Takes an array of albums and prints them to the terminal along with all of their tracks
def print_albums(albums)
    i = 0
    while i < albums.length
        puts "Album #{i}"
        print_album(albums[i])
        i += 1
    end
end
