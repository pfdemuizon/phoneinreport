require 'audiofile'

# Version 0.2: This script now works OK and does not fail.
# In an older version it caused Ruby to segfault (inside audiofile).

# change for your setup.
WORKING_AUDIO_FILE = "/home/jaredj/plasmoid.wav"

begin
    bytes_read = 10000
    while bytes_read > 0
        print bytes_read, " "
        bytes_read = bytes_read - 1
    end
rescue
end

begin
    f = AudioFile.new WORKING_AUDIO_FILE
    f.close
rescue
end
