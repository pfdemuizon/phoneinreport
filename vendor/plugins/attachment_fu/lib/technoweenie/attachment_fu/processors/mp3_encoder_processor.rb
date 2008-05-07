module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module Mp3EncoderProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end
        
        module ClassMethods
          def with_audio(file, &block)
            block.call file
          end
        end

        protected
          def process_attachment_with_processing
            return unless process_attachment_without_processing
            with_audio do |audio_file|
              wav_file = audio_file.clone
              audio_file.sub! /wav$/, 'mp3'
              RAILS_DEFAULT_LOGGER.info("lame -b 32 --resample 22050 #{wav_file} #{audio_file} 2>&1")
              RAILS_DEFAULT_LOGGER.info(`/usr/local/bin/lame -b 32 --resample 22050 #{wav_file} #{audio_file} 2>&1`)
              File.delete(wav_file)
              content_type.sub!(/wav$/, 'mp3')
              filename.sub! /wav$/, 'mp3'
            end if audio?
          end
      end
    end
  end
end
