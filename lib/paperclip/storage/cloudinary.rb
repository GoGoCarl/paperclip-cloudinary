module Paperclip
  module Storage
    module Cloudinary
      # You can download your configuration directly from Cloudinary to 
      # start using this gem immediately:
      #
      # https://cloudinary.com/console/cloudinary.yml

      def self.extended base
        begin
          require 'cloudinary'
        rescue LoadError => e
          e.message << ' (You may need to install the cloudinary gem)'
          raise e
        end
      end

      def flush_writes
        @queued_for_write.each do |style_name, file|
          defaults = {
            public_id: public_id(style_name),
            use_filename: true,
            unique_filename: false,
            overwrite: true
          }
          options = @options[:cloudinary_upload_options] || {}
          options.merge! defaults
          ::Cloudinary::Uploader.upload file, options
        end

        after_flush_writes

        @queued_for_write.clear
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          ::Cloudinary::Uploader.destroy path
        end

        @queued_for_delete.clear
      end

      def copy_to_local_file style, local_dest_path
        File.open(local_dest_path, 'wb') do |file|
          file.write ::Cloudinary::Downloader.download(path(style))
        end
      end

      def exists? style = default_style
        ::Cloudinary::Uploader.exists? path(style)
      end

      def url style_or_options = default_style, options = {}
        if style_or_options.is_a?(Hash)
          options.merge! style_or_options
          style = default_style
        else
          style = style_or_options
        end
        ::Cloudinary::Utils.cloudinary_url path(style)
      end

      def public_id style
        s = path style
        s[0..-(File.extname(s).length + 1)]
      end

      def cloud_name
        cloudinary_credentials[:cloud_name]
      end

      def api_key
        cloudinary_credentials[:api_key]
      end

      def api_secret
        cloudinary_credentials[:api_secret]
      end

      def cloudinary_credentials
        @cloudinary_credentials ||= parse_credentials(@options[:cloudinary_credentials] || Rails.root.join("config/cloudinary.yml"))
        @cloudinary_credentials
      end

      def parse_credentials creds
        creds = creds.respond_to?('call') ? creds.call(self) : creds
        creds = find_credentials(creds).stringify_keys
        env = Object.const_defined?(:Rails) ? Rails.env : nil
        (creds[env] || creds).symbolize_keys
      end

      private

      def find_credentials creds
        case creds
        when File
          YAML::load(ERB.new(File.read(creds.path)).result)
        when String, Pathname
          YAML::load(ERB.new(File.read(creds)).result)
        when Hash
          creds
        when NilClass
          {}
        else
          raise ArgumentError, "Credentials given are not a path, file, proc, or hash."
        end
      end

    end
  end
end
