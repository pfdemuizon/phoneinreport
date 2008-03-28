require 'mkmf'

dir_config("audiofile")
if have_library("audiofile", "afOpenFile") and have_header("audiofile.h")
    create_makefile("audiofile")
else
    print "*** ERROR: need to have all of this to compile this module\n"
end
