=begin RD

= ruby-audiofile
== a ruby binding to the audiofile library
== The underlying library

The ((<"http://dreamscape.68k.org/~michael/audiofile"|audiofile library>))
was originally proprietary to SGI, and was used in Irix to read and
write audio files of various types: wav, aiff, au, etc. After a bit of coding
by Michael Pruett, and a few more things, it's no longer proprietary, though 
some parts are not yet in existence. We'll talk about that later. But here's 

=== What audiofile does:

* Reads audio files of various types 
* Supports mu-law and A-law compression and uncompressed files
* Provides information on them, such as sampling rate, sample type, etc.
* Can switch byte order on the fly while reading, for user convenience
* Writes audio files
* Supports weird extensions (e.g. instruments in AIFF files, loops in WAV files)

=== But audiofile doesn't:

* Read MP3's
* Read Vorbis files (see ((<"http://www.xiph.org/ogg/vorbis/">)) for that)
* Write either of these
* Resample files on the fly while writing or reading (yet)
* Change sample formats or compression on the fly (yet)
* Support multitrack files (yet). It does support multiple ((*channels*)),
  i.e. stereo and whatnot, but doesn't support any formats yet that can store
  multiple ((*tracks*)).

== This binding

This extension is a binding of the audiofile library to the Ruby language. With
the aid of this super-wonderful extension, you can do everything you could do
with audiofile in Ruby, except:

=== Things supported by audiofile, but not ruby-audiofile

* reading non-raw files in a raw way
* handling errors elegantly (error handling works fairly well, but may
  need changes)
* querying the capabilities of the library itself (afQuery)
* messing with loops, instruments, text data, or anything but the audio itself
* doing anything that audiofile has API for, but doesn't actually support

The last item may need a small bit of explanation: there are a number of 
functions declared in audiofile.h (or commented out) which show that the
author has a clear idea of what it will look like to the user of the library
to use these not-yet-supported features, but there's not actually any code
behind these declarations. 

== ruby-audiofile version 0.2.1

Version 0.2 adds file writing support, and fixes a bug with #read where
it returned half the data it was supposed to. Also the API has changed
some; the real_ prefixes no longer exist and there is a new virtual_
prefix. This makes code using ruby-audiofile shorter and more succinct.

Version 0.2.1 takes out a couple of debugging printf's i accidentally left in,
and changes the width/width= methods to bits/bits= to fit better with
Linux::SoundDSP. Minor documentation changes as well.

Version 0.2.2 has more documentation changes, and an update to my email
address.

== How to install
  ruby extconf.rb
  make
  sudo make install

== How to use

In your scripts,
  require 'audiofile'
This defines the AudioFile class, which has the following methods:

=== AudioFile class

--- AudioFile.new( filename, [mode] )
--- AudioFile.open( filename, [mode] )
Open a new AudioFile and return it. The mode is either "r" or "w" - for read or
write.

If you open a file for writing, you must set the following properties before
writing to the file:

* rate
* bits
* channels
* byte_order
* compression
* file_format
* sample_format

If you do not set these properties before calling the #write method, the
results are unspecified.

--- AudioFile#close
Close the file.

--- AudioFile#read( [frames] )
Read frames frames from the file. A ((:frame:)) is one sample for each channel.
So in a 44100Hz, 16-bit, stereo file, a frame would take four bytes: two for 
the left channel, and two for the right. (Two bytes is 16 bits of course.)
This returns a new string every time, so if you're reading many times from an
audio file, read_into is suggested. That way your script will not grow huge in
memory.

--- AudioFile#read_into( string )
Read into string from the file. This replaces the contents of the string by 
reading the largest number of frames that will fit into the current length of
the string. It returns the number of bytes actually read. Example:
  string = " " * 32
  file.read_into(string)

--- AudioFile#write( string )
Write the string to the file. See the note under #open: in short, you must set
the properties of the file before writing to it.

Also note that both #read_into and #write round to the frame. That is,
read_into will only read as many whole frames as fit into the string you give
it, and write will only write as many whole frames as are contained in the
string you pass to it.

--- AudioFile#flush
Flush the write buffers for the file.

--- AudioFile#pos
Returns the current position inside the file, in frames. (See #read about
what frames are.)

--- AudioFile#pos=( [new_pos] )
Move to a new position inside the file. The position is specified in frames.
You cannot move backwards inside the file; #pos= will throw an exception if you
do. 

--- AudioFile#frame_count
Returns how many frames are in this file.

--- AudioFile#virtual_byte_order=( [new_byte_order] )
Sets the virtual byte order. new_byte_order should be either
AudioFile::BIG_ENDIAN or AudioFile::LITTLE_ENDIAN. 

When you read from the file, this byte order is the one the results will come
back in. So if you are reading a little-endian file and you use
#virtual_byte_order= AudioFile::BIG_ENDIAN, then #read, the data you get will
be in big-endian byte order, because the library will switch the bytes on the
fly.

Conversely, if you are writing a file, and you set the virtual byte order,
audiofile will take the bytes you give it in the virtual byte order, and swap
them if needed in order to get them into the file in the real byte order.

--- AudioFile#virtual_byte_order
Returns the virtual byte order. This will be one of:
* AudioFile::BIG_ENDIAN
* AudioFile::LITTLE_ENDIAN

--- AudioFile#byte_order
Returns the real byte order. See the constants above. This is the byte
order in which the file is stored and does not change when you use
#virtual_byte_order=.

--- AudioFile#byte_order=
Sets the byte order in which the file will be written. For use when writing
files only. Use before actually writing to the file.

--- AudioFile#compression
Returns the compression type, which will be one of:
* AudioFile::UNKNOWN
* AudioFile::NONE
* AudioFile::G722
* AudioFile::G711_ULAW
* AudioFile::G711_ALAW

Or one of these, which are detected but unsupported by the audiofile library:
* AudioFile::APPLE_ACE2
* AudioFile::APPLE_ACE8
* AudioFile::APPLE_MAC3
* AudioFile::APPLE_MAC6
* AudioFile::G726
* AudioFile::G728
* AudioFile::DVI_AUDIO
* AudioFile::GSM
* AudioFile::FS1016

--- AudioFile#compression=
Sets the compression type. See the constants above. For use when
writing files only. Use before actually writing to the file.

--- AudioFile#sample_format
Returns the sample format, which will be one of:
* AudioFile::TWOS_COMPLEMENT
* AudioFile::UNSIGNED
* AudioFile::FLOAT
* AudioFile::DOUBLE

--- AudioFile#sample_format=
Sets the sample format. See the constants above. For use when
writing files only. Use before actually writing to the file.

--- AudioFile#bits
Returns the number of bits in a sample. Commonly, this is 8 or 16. Some of the
file formats supported support sample widths greater than 16, which are usually
24 or 32. The default behavior is to pad 24-bit samples to 32 bits for speed of
handling (and to expect padded samples when writing, thus throwing away every
fourth byte). To change this, look for the EXPAND_3TO4 define in the source
(audiofile.c, around line 90), change and recompile.

--- AudioFile#bits=
Sets the number of bits in a sample. For use when writing files only. Use
before actually writing to the file.

--- AudioFile#rate
Returns the number of samples per second. (commonly 44100, 22050, etc.)

--- AudioFile#rate=
Sets the number of samples per second. For use when writing files
only. Use before actually writing to the file.

--- AudioFile#channels
Returns the number of channels. (commonly 1 or 2)

--- AudioFile#channels=
Sets the number of channels. For use when writing files only. Use before
actually writing to the file.

--- AudioFile#pcm_mapping
Returns an array containing four floats. See below.

--- AudioFile#pcm_mapping=( param )
param is an array containing four floats, corresponding to the slope, 
intercept, minimum clip and maximum clip values. This alters how the library
sees the samples. Example:
  file.real_pcm_mapping = [0.0, 1.0, -1.0, 1.0]
The numbers define a piecewise linear function through which sample values are
mapped. By changing this, you can do things like make audiofile double all the
sample values it reads on the fly before you see them.

== About the virtual_ prefix on method names
The audiofile library (ideally) supports complete virtualization of all
parameters of a sound file (sampling frequency, sample type, compresson...)
such that the library would translate on the fly from the format in the file to
the format the user of the library wishes to see. All of this support isn't in
place yet: in fact, the only thing that is virtualized right now is the byte
order. So when complete virtualization is supported, this binding will have
#virtual_sample_rate=, #virtual_sample_format=, etc. methods. Right now there's
only #virtual_byte_order and #virtual_byte_order=.

== Have fun with it!
If you have any more questions about ruby-audiofile, you can look at the source
(by the way, many thanks to matz for writing extensions before I did; I copied
the structure of my extension from gdbm, which he wrote). Or you can ask me
questions at ((<"mailto:jjenning@fastmail.fm"|jjenning@fastmail.fm>)).

If you use this extension, I'd love to know! Email me and tell me.

== Possible future features
* querying the library for its capabilities. 
* reading and writing non-strictly-audio data parts like instruments and loops.

The methods that return constants will hopefully end up more elegant in
some way.
