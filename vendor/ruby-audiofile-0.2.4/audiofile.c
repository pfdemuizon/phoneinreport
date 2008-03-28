/*********************************************************
                                                        
   audiofile.c

   a Ruby extension to bind Ruby to audiofile
   (http://dreamscape.68k.org/~michael/audiofile/)

   patterned very very closely off of gdbm.c by matz in
   the ruby 1.6.4 distribution. very closely. thanks matz!

  $Author: jaredj $
  $Date: 2001/07/26 04:31:45 $

*********************************************************/

/* conventions:
 *
 * _s_ in function name: singleton method
 * fh                  : filehandle
 * fn                  : filename
 * af                  : audiofile
 * p                   : pointer
 */

/* assumptions:
 * you always mean AF_DEFAULT_TRACK.
 *   the audiofile lib currently supports only formats with one track.
 *   so we'll always use AF_DEFAULT_TRACK, at least for
 *   this version of the bindings.
 *   (this doesn't mean one *channel*; stereo files are fully supported.)
 *
 *
 * you will always set everything about the file before attempting to write it.
 * (rate, bits, channels, byte_order, compression, file_format, sample_format)
 */

/* things supported:
 *
 * opening/closing/flushing audio files
 * reading frames into a new string and an existing one
 * NEW: writing audio files from strings
 * NEW: setting things about files to be created (sample rate, etc)
 * moving forward/telling position in a file
 * getting frame count & size 
 * getting real sample rate 
 * getting real byte order
 * getting/setting virtual byte order
 * calling all this from ruby
 *
 */

/* things not yet supported (in order of importance):
 *
 * raw-reading files well 
 *     (afInitDataOffset not supported, so you can't skip headers easily)
 * setting parameters for compression schemes when writing
 *     (this might make the ability to set the compression scheme useless)
 * really correct error handling
 * querying the capabilities of the audiofile library (afQuery)
 * things relating to loops, instruments or non-strictly-audio data
 * things that audiofile has API for but doesn't actually support yet
 *    (e.g., virtual sample rates and virtual compression schemes)
 */

/* open doesn't appear to work, even though i copied it straight from
 * matz's gdbm extenstion. */

#include "ruby.h"
#include <audiofile.h>

static VALUE cAudioFile, rb_eAudioFileError;

/* I know AFfilehandle is just a struct _AFfilehandle *
 * but i chose to keep it in its own structure instead of
 * just using the _AFfilehandle structure for future
 * expansibility and caching stuff, like matz did in 
 * the gdbm ext.
 */

struct af_data {
    char *name;
//    char mode;
    int sample_format;
    int sample_width;
    AFfilehandle handle;
    AFfilesetup setup;
};


    /* this will pad 24-bit values to 32 bits.
     * replace 1 with 0 to disable */
#define EXPAND_3TO4 1

static VALUE af_close(VALUE obj);


static void closed_af()
{
    rb_raise(rb_eRuntimeError, "audio file already closed");
}

#define GetAFP(obj, afp) {\
    Data_Get_Struct(obj, struct af_data, afp);\
    if(afp == NULL) closed_af();\
    if(afp->handle == AF_NULL_FILEHANDLE) closed_af();\
}

#define GetAFPWithoutOpenChecking(obj, afp) {\
    Data_Get_Struct(obj, struct af_data, afp);\
}

static void free_af(struct af_data *afp)
{
    if(afp) {
        if(afp->handle) {
            afCloseFile(afp->handle);
            /* the error handler will get it */
        }
        if(afp->setup) {
            afFreeFileSetup(afp->setup);
        }
        if(afp->name) {
            free(afp->name);
        }
        free(afp);
    }
}

static int af_is_open(struct af_data *afp)
{
    if(afp) {
        return (afp->handle != NULL);
    } else {
        rb_raise(rb_eRuntimeError, "somehow an AudioFile with no data was asked if it was open");
        return 0;
    }
}

static VALUE af_initialize(int argc, VALUE *argv, VALUE obj)
{
    AFfilehandle fh;
    struct af_data *afp;
/*    struct af_file_setup *fsp;
    AFfilesetup file_setup; */
    char *mode, *fn;

    VALUE v_return;
    VALUE v_fn, v_mode, v_file_setup;


    switch(rb_scan_args(argc, argv, "12", &v_fn, &v_mode, &v_file_setup)) {
        case 1: /* only filename specified. use default (read) */
            
            mode = malloc(2);
            mode[0] = 'r';
            mode[1] = '\0';

            break;
        case 2:  /* filename & mode */
            Check_Type(v_mode, T_STRING);

            /* get mode into a C-string */
            mode = malloc(2);
            mode[0] = *(RSTRING(v_mode)->ptr);
            mode[1] = '\0';

            switch(*mode) {
                case 'r':
                case 'w':
                    /* OK */
                    break;
                default:
                    rb_raise(rb_eArgError, "unknown mode specification");
                    break;
            }
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments");
            break;
    }

    Check_Type(v_fn, T_STRING);

    /* i don't know exactly what this does, but matz did it so it must work :) */
    v_fn = rb_str_to_str(v_fn);
    Check_SafeStr(v_fn);

    switch(*mode) {
        case 'r':

            fh = afOpenFile(RSTRING(v_fn)->ptr, mode, AF_NULL_FILESETUP);
            if(fh != AF_NULL_FILEHANDLE) {
                afp = ALLOC(struct af_data);
                DATA_PTR(obj) = afp;

                /* default sample format and width. see af_sample_format_eq 
                 * below for details about this ugly hack. */

                afp->sample_format = AF_SAMPFMT_TWOSCOMP;
                afp->sample_width = 16;

                afp->name = NULL;
                afp->setup = AF_NULL_FILESETUP;
                afp->handle = fh;

                v_return = obj;
            } else {
                v_return = Qnil;
            }
            free(mode);
            break;

        case 'w':
            
            fn = malloc(RSTRING(v_fn)->len+1);
            strcpy(fn, RSTRING(v_fn)->ptr);

            afp = ALLOC(struct af_data);
            DATA_PTR(obj) = afp;

            afp->sample_format = AF_SAMPFMT_TWOSCOMP;
            afp->sample_width = 16;

            afp->name = fn;
            afp->handle = AF_NULL_FILEHANDLE;
            afp->setup = afNewFileSetup();

            v_return = obj;
            free(mode);
            break;

        default:
            free(mode);
            rb_raise(rb_eArgError, "unknown mode specified");
            break;
    } 

    return v_return;
}


static VALUE af_s_new(int argc, VALUE *argv, VALUE klass)
{
    /* i don't know what the last param is in this 'call' */

    VALUE obj = Data_Wrap_Struct(klass, 0, free_af, 0);
    rb_obj_call_init(obj, argc, argv);
    return obj;
}

/*      ---------------- fundamental methods -------------------------*/

static VALUE af_s_open(int argc, VALUE *argv, VALUE klass) 
{
   
    VALUE obj = Data_Wrap_Struct(klass, 0, free_af, 0);

    if(NIL_P(af_initialize(argc, argv, obj))) {
        return Qnil;
    }

    if(rb_block_given_p()) {
        return rb_ensure(rb_yield, obj, af_close, obj);
    }

    return obj;
}

static VALUE af_close(VALUE obj)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);
    if(af_is_open(afp)) {
        afCloseFile(afp->handle);
        afp->handle = AF_NULL_FILEHANDLE;
    }

    return Qnil;
}

static VALUE af_flush(VALUE obj)
{
    struct af_data *afp;
    
    GetAFP(obj, afp);
    if(af_is_open(afp)) {
        afSyncFile(afp->handle);
    }

    return obj;
}



static VALUE af_read(int argc, VALUE *argv, VALUE obj)
{
    VALUE v_frames;
    VALUE returnString;
    struct af_data *afp;
    long int frames, actual_frames, frame_size;
    long int bytes, actual_bytes;
    void *buf;

    GetAFP(obj, afp);
    if(rb_scan_args(argc, argv, "01", &v_frames) == 1) {
        if(FIXNUM_P(v_frames)) {
            frames = NUM2INT(v_frames);
        } else {
            rb_raise(rb_eArgError, "invalid argument to AudioFile#read");
        }
    } else {
        frames = afGetFrameCount(afp->handle, AF_DEFAULT_TRACK);
    }

    frame_size = afGetFrameSize(afp->handle, AF_DEFAULT_TRACK, EXPAND_3TO4);
    bytes = frames * frame_size;
    buf = malloc(bytes);

    actual_frames = afReadFrames(afp->handle, AF_DEFAULT_TRACK, buf, frames);
    actual_bytes = actual_frames * frame_size;

    returnString = rb_str_new(buf, actual_bytes);
    return returnString;
}

static VALUE af_read_into(VALUE obj, VALUE readIntoString)
{
    struct af_data *afp;
    long int frames, actual_frames, frame_size;
    long int bytes, actual_bytes;
    void *buf;

    GetAFP(obj, afp);
    

    Check_Type(readIntoString, T_STRING);
    bytes = RSTRING(readIntoString)->len;
    buf = RSTRING(readIntoString)->ptr;

    frame_size = afGetFrameSize(afp->handle, AF_DEFAULT_TRACK, EXPAND_3TO4);
    frames = bytes / frame_size;

    actual_frames = afReadFrames(afp->handle, AF_DEFAULT_TRACK, buf, frames);
    actual_bytes = actual_frames * frame_size;

    return INT2NUM(actual_bytes);
}

static VALUE actually_write(VALUE obj, VALUE writeFromString)
{
    struct af_data *afp;
    long int frames, actual_frames, frame_size;
    long int bytes, actual_bytes;
    void *buf;

    GetAFP(obj, afp);

    Check_Type(writeFromString, T_STRING);
    bytes = RSTRING(writeFromString)->len;
    buf = RSTRING(writeFromString)->ptr;

    frame_size = afGetFrameSize(afp->handle, AF_DEFAULT_TRACK, EXPAND_3TO4);
    frames = bytes / frame_size;

    actual_frames = afWriteFrames(afp->handle, AF_DEFAULT_TRACK, buf, frames);
    actual_bytes = actual_frames * frame_size;

    return INT2NUM(actual_bytes);
}

static VALUE af_write(VALUE obj, VALUE writeFromString)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);
    if(af_is_open(afp)) {
        return actually_write(obj, writeFromString);
    } else {
        if(afp->name) {
            afp->handle = afOpenFile(afp->name, "w", afp->setup);
            free(afp->name);
            afp->name = NULL;

            return actually_write(obj, writeFromString);
        } else {
            rb_raise(rb_eAudioFileError, "write attempted on apparently unopenable file");
			return Qnil;
        }
    }
}



/* ------ getters --------------------------------------------------------*/

static VALUE af_frame_size(VALUE obj)
{
    struct af_data *afp;

    GetAFP(obj, afp);
    return INT2NUM((afGetFrameSize(afp->handle, AF_DEFAULT_TRACK, EXPAND_3TO4)));
}

static VALUE af_frame_count(VALUE obj)
{
    struct af_data *afp;

    GetAFP(obj, afp);
    return INT2NUM((afGetFrameCount(afp->handle, AF_DEFAULT_TRACK)));
}

static VALUE af_pos(VALUE obj)
{
    struct af_data *afp;

    GetAFP(obj, afp);
    return INT2NUM((afTellFrame(afp->handle, AF_DEFAULT_TRACK)));
}

static VALUE af_sample_rate(VALUE obj)
{
    struct af_data *afp;

    GetAFP(obj, afp);
    return INT2NUM((afGetRate(afp->handle, AF_DEFAULT_TRACK)));
}


static VALUE af_byte_order(VALUE obj)
{
    struct af_data *afp;
    int byte_order;

    GetAFP(obj, afp);
    byte_order = afGetByteOrder(afp->handle, AF_DEFAULT_TRACK);

    /* for now */
    return INT2NUM(byte_order);
}

static VALUE af_virtual_byte_order(VALUE obj)
{
    struct af_data *afp;
    int byte_order;

    GetAFP(obj, afp);
    byte_order = afGetVirtualByteOrder(afp->handle, AF_DEFAULT_TRACK);

    /* for now */
    return INT2NUM(byte_order);
}

static VALUE af_channels(VALUE obj)
{
    struct af_data *afp;

    GetAFP(obj, afp);

    return INT2NUM(afGetChannels(afp->handle, AF_DEFAULT_TRACK));
}


static VALUE af_sample_format(VALUE obj)
{
    struct af_data *afp;
    int format, width;

    GetAFP(obj, afp);
    
    afGetSampleFormat(afp->handle, AF_DEFAULT_TRACK, &format, &width);
    return INT2FIX(format);
}

static VALUE af_sample_width(VALUE obj)
{
    struct af_data *afp;
    int format, width;

    GetAFP(obj, afp);

    afGetSampleFormat(afp->handle, AF_DEFAULT_TRACK, &format, &width);
    return INT2FIX(width);
}

static VALUE af_compression(VALUE obj)
{
    struct af_data *afp;

    GetAFP(obj, afp);

    return INT2NUM(afGetCompression(afp->handle, AF_DEFAULT_TRACK));
}

static VALUE af_pcm_mapping(VALUE obj)
{
    struct af_data *afp;
    double slope, intercept, min_clip, max_clip;

    GetAFP(obj, afp);

    afGetPCMMapping(afp->handle, AF_DEFAULT_TRACK, &slope, 
            &intercept, &min_clip, &max_clip);

    return rb_ary_new3(4, 
            rb_float_new(slope),
            rb_float_new(intercept),
            rb_float_new(min_clip),
            rb_float_new(max_clip));
}


static VALUE af_file_format(VALUE obj)
{
    struct af_data *afp;
    int ver;

    GetAFP(obj, afp);

    return INT2NUM(afGetFileFormat(afp->handle, &ver));
}

static VALUE af_file_format_version(VALUE obj)
{
    struct af_data *afp;
    int ver;

    GetAFP(obj, afp);
    afGetFileFormat(afp->handle, &ver);

    return INT2NUM(ver);
}

/*
 * ------ setters -------------------------------------------------------- 
 */

static VALUE af_pos_eq(VALUE obj, VALUE new_pos)
{
    struct af_data *afp;
    AFfileoffset here, there;

    GetAFP(obj, afp);
    here = afTellFrame(afp->handle, AF_DEFAULT_TRACK);
    there = NUM2INT(new_pos);
    if(there >= here) {
        return INT2NUM((afSeekFrame(afp->handle, AF_DEFAULT_TRACK, (there - here))));
    } else {
        rb_raise(rb_eArgError, "cannot seek backwards");
    }
}


#define ATTEMPT(foo) ("attempt to set " foo " on an already-open file")
static void bail_if_open(struct af_data *afp, const char *message)
{
    if(af_is_open(afp)) {
        rb_raise(rb_eAudioFileError, message);
    }
}

static VALUE af_file_format_eq(VALUE obj, VALUE format)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);
    bail_if_open(afp, ATTEMPT("file format"));

    afInitFileFormat(afp->setup, NUM2INT(format));
    return format;
}

static VALUE af_sample_rate_eq(VALUE obj, VALUE rate)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);

    bail_if_open(afp, ATTEMPT("sample rate"));
    
    afInitRate(afp->setup, AF_DEFAULT_TRACK, NUM2INT(rate));
    return rate;
}

static VALUE af_byte_order_eq(VALUE obj, VALUE byte_order)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);
    bail_if_open(afp, ATTEMPT("byte order"));

    afInitByteOrder(afp->setup, AF_DEFAULT_TRACK, NUM2INT(byte_order));
    return byte_order;
}

static VALUE af_virtual_byte_order_eq(VALUE obj, VALUE new_bo)
{
    struct af_data *afp;

    GetAFP(obj, afp);
    
    /* for now */
    afSetVirtualByteOrder(afp->handle, AF_DEFAULT_TRACK, NUM2INT(new_bo));

    return new_bo;
}

static VALUE af_channels_eq(VALUE obj, VALUE channels)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);

    bail_if_open(afp, ATTEMPT("channels"));

    afInitChannels(afp->setup, AF_DEFAULT_TRACK, NUM2INT(channels));
    return channels;
}

/* Details about this dirty hack.
 * I added two members, sample_format and sample_width, to the
 * af_data structure because you can only set them both at a time,
 * and you can't get inside the AFfilesetup structure prettily.
 * So those are to preserve what you set the sample_format to so
 * that the sample_width can set it to that, and vice versa.
 * They only have defaults so that your program won't barf if you 
 * don't explicitly set one or both. Course, your program will barf
 * if you don't set the rest of the stuff in the filesetup structure
 * anyway... unless afNewFileSetup makes the new filesetup have defaults
 *
 */

static VALUE af_sample_format_eq(VALUE obj, VALUE sample_format)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);
    bail_if_open(afp, ATTEMPT("sample format"));

    afp->sample_format = NUM2INT(sample_format);
    afInitSampleFormat(afp->setup, AF_DEFAULT_TRACK, 
            afp->sample_format,
            afp->sample_width);
    return sample_format;
}

static VALUE af_sample_width_eq(VALUE obj, VALUE sample_width)
{
    struct af_data *afp;

    GetAFPWithoutOpenChecking(obj, afp);
    bail_if_open(afp, ATTEMPT("sample width"));

    afp->sample_width = NUM2INT(sample_width);
    afInitSampleFormat(afp->setup, AF_DEFAULT_TRACK, 
            afp->sample_format,
            afp->sample_width);
    return sample_width;
}

static VALUE af_compression_eq(VALUE obj, VALUE compression)
{
    struct af_data *afp;
    GetAFPWithoutOpenChecking(obj, afp);
    bail_if_open(afp, ATTEMPT("compression scheme"));

    afInitCompression(afp->setup, AF_DEFAULT_TRACK, NUM2INT(compression));
	return compression;
}

           



static VALUE af_pcm_mapping_eq(VALUE obj, VALUE args)
{
    VALUE v_slope, v_intercept, v_min_clip, v_max_clip;
/*    double slope, intercept, min_clip, max_clip; */
    struct af_data *afp;

    Check_Type(args, T_ARRAY);
    if(RARRAY(args)->len != 1) {
        rb_raise(rb_eArgError, "incorrect argument(s) to AudioFile#pcm_mapping=");
    }
    args = *(RARRAY(args)->ptr);
    if(RARRAY(args)->len != 4) {
        rb_raise(rb_eArgError, "incorrect argument(s) to AudioFile#pcm_mapping=");
    }

    v_slope     = RARRAY(args)->ptr[0];
    v_intercept = RARRAY(args)->ptr[1];
    v_min_clip  = RARRAY(args)->ptr[2];
    v_max_clip  = RARRAY(args)->ptr[3];
    Check_Type(v_slope, T_FLOAT);
    Check_Type(v_intercept, T_FLOAT);
    Check_Type(v_min_clip, T_FLOAT);
    Check_Type(v_max_clip, T_FLOAT);

    GetAFPWithoutOpenChecking(obj, afp);

    if(af_is_open(afp)) {
        afSetTrackPCMMapping(afp->handle, AF_DEFAULT_TRACK, 
                RFLOAT(v_slope)->value, RFLOAT(v_intercept)->value,
                RFLOAT(v_min_clip)->value, RFLOAT(v_max_clip)->value);
    } else {
        afInitPCMMapping(afp->setup, AF_DEFAULT_TRACK, 
                RFLOAT(v_slope)->value, RFLOAT(v_intercept)->value,
                RFLOAT(v_min_clip)->value, RFLOAT(v_max_clip)->value);
    }

    return Qnil;
}


void af_error_function(long error_num, const char *message)
{
    rb_raise(rb_eAudioFileError, message);
}

void Init_audiofile()
{
    struct {
        const char *name;
        VALUE (*func)();
        int args;
    } instance_methods[] = {
        { "initialize", af_initialize, -1   },
        { "close", af_close, 0   },
        { "read", af_read, -1   },
        { "flush", af_flush, 0   },
        { "write", af_write, 1   },
        { "read_into", af_read_into, 1   },
        { "frame_size", af_frame_size, 0   },
        { "frame_count", af_frame_count, 0   },

        /* getters */
        { "pos", af_pos, 0   },
        { "rate", af_sample_rate, 0   },
        { "bits", af_sample_width, 0   },
        { "channels", af_channels, 0   },
        { "byte_order", af_byte_order, 0 },
        { "compression", af_compression, 0   },
        { "file_format", af_file_format, 0   },
        { "sample_format", af_sample_format, 0   },
        { "virtual_byte_order", af_virtual_byte_order, 0 },
        { "pcm_mapping", af_pcm_mapping, 0 },
        { "file_format_version", af_file_format_version, 0   },

        /* setters */
        { "pos=", af_pos_eq, 1   },
        { "rate=", af_sample_rate_eq, 1  },
        { "bits=", af_sample_width_eq, 1  },
        { "channels=", af_channels_eq, 1  },
        { "byte_order=", af_byte_order_eq, 1 },
        { "compression=", af_compression_eq, 1 },
        { "file_format=", af_file_format_eq, 1 },
        { "sample_format=", af_sample_format_eq, 1  },
        { "virtual_byte_order=", af_virtual_byte_order_eq, 1 },
        { "pcm_mapping=", af_pcm_mapping_eq, -2 },
        { 0 }
    };

    struct {
        const char *name;
        VALUE value;
    } constants[] = {
        { "BIG_ENDIAN", INT2FIX(AF_BYTEORDER_BIGENDIAN) },
        { "LITTLE_ENDIAN", INT2FIX(AF_BYTEORDER_LITTLEENDIAN) },

        { "TWOS_COMPLEMENT", INT2FIX(AF_SAMPFMT_TWOSCOMP) },
        { "UNSIGNED", INT2FIX(AF_SAMPFMT_UNSIGNED) },
        { "FLOAT", INT2FIX(AF_SAMPFMT_FLOAT) },
        { "DOUBLE", INT2FIX(AF_SAMPFMT_DOUBLE) },

        { "COMPRESSION_UNKNOWN", INT2FIX(AF_COMPRESSION_UNKNOWN) },
        { "NONE", INT2FIX(AF_COMPRESSION_NONE) },
        { "G722", INT2FIX(AF_COMPRESSION_G722) },
        { "G711_ULAW", INT2FIX(AF_COMPRESSION_G711_ULAW) },
        { "G711_ALAW", INT2FIX(AF_COMPRESSION_G711_ALAW) },
        { "APPLE_ACE2", INT2FIX(AF_COMPRESSION_APPLE_ACE2) },
        { "APPLE_ACE8", INT2FIX(AF_COMPRESSION_APPLE_ACE8) },
        { "APPLE_MAC3", INT2FIX(AF_COMPRESSION_APPLE_MAC3) },
        { "APPLE_MAC6", INT2FIX(AF_COMPRESSION_APPLE_MAC6) },
        { "G726", INT2FIX(AF_COMPRESSION_G726) },
        { "G728", INT2FIX(AF_COMPRESSION_G728) },
        { "DVI_AUDIO", INT2FIX(AF_COMPRESSION_DVI_AUDIO) },
        { "GSM", INT2FIX(AF_COMPRESSION_GSM) },
        { "FS1016", INT2FIX(AF_COMPRESSION_FS1016) },

        { "FILE_UNKNOWN", INT2FIX(AF_FILE_UNKNOWN) },
        { "RAW", INT2FIX(AF_FILE_RAWDATA) },
        { "AIFF_C", INT2FIX(AF_FILE_AIFFC) },
        { "AIFF", INT2FIX(AF_FILE_AIFF) },
        { "NEXT_SND", INT2FIX(AF_FILE_NEXTSND) },
        { "WAV", INT2FIX(AF_FILE_WAVE) },
        { 0 }
    };

    int i;

    afSetErrorHandler(af_error_function);

    cAudioFile = rb_define_class("AudioFile", rb_cObject);
    rb_eAudioFileError = rb_define_class("AudioFileError", rb_eStandardError);
    
    rb_define_singleton_method(cAudioFile, "new", af_s_new, -1);
    rb_define_singleton_method(cAudioFile, "open", af_s_open, -1);

    for(i=0; instance_methods[i].name; i++) {
        rb_define_method(cAudioFile, instance_methods[i].name,
                instance_methods[i].func, instance_methods[i].args);
    }

/*rb_define_method(cAudioFile, "pcm_mapping", af_pcm_mapping, 0);
 *
 * afGetPCMMapping is declared in audiofile.h, but not defined in 
 * libaudiofile.so! So I can't call it. So this method doesn't get defined.
 *
 */


/*
 * these might need synchronization with other people's constants
 * this would require changing the sample_format and other functions
 * (see "for now" in above functions.)
 *
 */

    for(i=0; constants[i].name; i++) {
        rb_define_const(cAudioFile, constants[i].name, constants[i].value);
    }

}
