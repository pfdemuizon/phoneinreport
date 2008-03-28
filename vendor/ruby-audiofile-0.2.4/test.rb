require './audiofile'

# change for your setup.
WORKING_AUDIO_FILE = "/home/jaredj/plasmoid.wav"
WRITING_AUDIO_FILE = "/home/jaredj/plasmoid-new.wav"

# this should be nonexistent, or try files with the wrong format, etc
BOGUS_AUDIO_FILE = "/home/jaredj/wuhwiuthw4otwoti"

begin 
    one = AudioFile.new
rescue
    print "OK    ! illegal # parameters to AudioFile.new fails\n"
    print "    ", $!, "\n\n"
end

begin
    two = AudioFile.new WORKING_AUDIO_FILE
    two.close
    three = AudioFile.new WORKING_AUDIO_FILE,"r"
    three.close
rescue
    print "FAILED! Opening #{WORKING_AUDIO_FILE} for reading\n"
    print "    ", $!, "\n\n"
end

begin
    three_half = AudioFile.open WORKING_AUDIO_FILE
    three_half.close
rescue
    print "FAILED! AudioFile.open doesn't work\n"
    print "    ", $!, "\n\n"
end

begin
    AudioFile.open(WORKING_AUDIO_FILE) do |file|
        a = 4
    end
rescue
    print "FAILED! AudioFile.open with block doesn't work\n"
    print "    ", $!, "\n\n"
end




begin 
    four = AudioFile.new WORKING_AUDIO_FILE,"w"
    four.close
rescue
    print "OK    ! Writing doesn't work without a FileSetup\n"
    print "        (In this version, writing doesn't work at all)\n"
    print "    ", $!, "\n\n"
end

begin
    five = AudioFile.new WORKING_AUDIO_FILE,"foo"
    five.close
rescue
    print "OK    ! AudioFile.new with nonsense mode fails\n"
    print "    ", $!, "\n\n"
end

begin
    six = AudioFile.new BOGUS_AUDIO_FILE
rescue
    print "OK    ! Opening nonexistent or unsupported files doesn't work\n"
    print "    ", $!, "\n\n"
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    [
     "pos",
     "rate",
     "bits",
     "channels",
     "byte_order", 
     "compression", 
     "file_format",
     "sample_format",
     "virtual_byte_order", 
     "file_format_version",
     "frame_count",
     "frame_size",
    ].each { |method|
        print "    ", method, " = ", f.instance_eval(method), "\n"
    }
rescue
    print "FAILED! Getting info about #{WORKING_AUDIO_FILE} doesn't work\n"
    print "    ", $!, "\n\n"
ensure
    f.close
end

# take these $stdout.flush'es out and Ruby crashes when you run this script
# for minimum case that causes the error, see fail.rb

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    string = " " * 10000;
    bytes_read = 1
    print "Reading from #{WORKING_AUDIO_FILE}... "
    $stdout.flush
    while bytes_read > 0
        bytes_read = f.read_into(string)
        print bytes_read, " "
        $stdout.flush
    end
    print "\n"
rescue
    print "FAILED! Couldn't read #{WORKING_AUDIO_FILE} properly.\n"
    print "    ", $!, "\n\n"
ensure
    f.close
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    f.pos
    f.pos=100
rescue
    print "FAILED! Couldn't seek/tell within #{WORKING_AUDIO_FILE}.\n"
    print "    ", $!, "\n\n"
ensure
    f.close
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    f.pos=100
    f.pos=0
rescue
    print "OK    ! Couldn't seek backwards within #{WORKING_AUDIO_FILE}.\n"
    print "    ", $!, "\n\n"
ensure
    f.close
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    f.pcm_mapping= [0.1,0.9,0.1,0.9]
rescue
    print "FAILED! Changing PCM mapping doesn't work\n"
    print "    ", $!, "\n\n"
ensure
    f.close
end




# writing tests

begin
    g = AudioFile.new WRITING_AUDIO_FILE, "w"
rescue
    print "FAILED! Couldn't open #{WRITING_AUDIO_FILE} for writing.\n"
    print "    ", $!, "\n\n"
ensure
    g.close
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    g = AudioFile.new WRITING_AUDIO_FILE, "w"

    g.rate= f.rate
    g.bits= f.bits
    g.channels= f.channels
    g.byte_order= f.byte_order
    g.compression= f.compression
    g.file_format= f.file_format
    g.sample_format= f.sample_format

rescue
    print "FAILED! Couldn't change things about #{WRITING_AUDIO_FILE} while writing.\n"
    print "    ", $!, "\n\n"
ensure
    f.close
    g.close
end

begin
    g = AudioFile.new WRITING_AUDIO_FILE, "w"

    g.rate= 44100
    g.write "poit"
    g.bits= 16
rescue 
    print "OK    ! Couldn't set things about a file after opening it for writing\n"
    print "    ", $!, "\n\n"
ensure
    g.close
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    g = AudioFile.new WRITING_AUDIO_FILE, "w"

    g.rate= f.rate
    g.bits= f.bits
    g.channels= f.channels
    g.byte_order= f.byte_order
    g.compression= f.compression
    g.file_format= f.file_format
    g.sample_format= f.sample_format

    print "Copying: "
    bytes_read = 1
    while(bytes_read != 0)
        str = f.read 10000
        bytes_read = str.length
        print "read #{bytes_read} - "
        $stdout.flush
        bytes_written = g.write str
        print "wrote #{bytes_written} - "
    end
    print "done!\n"
rescue
    print "FAILED! Couldn't write #{WRITING_AUDIO_FILE}\n"
    print "    ", $!, "\n\n"
ensure
    f.close
    g.close
end

puts "Now play #{WORKING_AUDIO_FILE} and #{WRITING_AUDIO_FILE}."
puts "They should sound the same"
