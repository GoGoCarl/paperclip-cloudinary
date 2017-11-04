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
            resource_type: resource_type,
            use_filename: true,
            unique_filename: false,
            overwrite: true,
            invalidate: true
          }
          upload_opts  = @options[:cloudinary_upload_options] || {}
          default_opts = upload_opts[:default] || {}
          style_opts   = upload_opts[:styles].try(:[], style_name) || {}

          options = {}
          [default_opts, style_opts].each do |opts|
            options.deep_merge!(opts) do |key, existing_value, new_value|
              new_value.try(:call, style_name, self) || new_value
            end
          end
          options.merge! defaults
          ::Cloudinary::Uploader.upload file, options
        end

        after_flush_writes

        @queued_for_write.clear
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          defaults = {
            resource_type: resource_type,
            invalidate: true
          }
          ::Cloudinary::Uploader.destroy public_id_for_path(path), defaults
        end

        @queued_for_delete.clear
      end

      def copy_to_local_file style, local_dest_path
        File.open(local_dest_path, 'wb') do |file|
          file.write ::Cloudinary::Downloader.download(url(style))
        end
      end

      def exists? style = default_style
        ::Cloudinary::Uploader.exists? public_id(style), cloudinary_url_options(style)
      end

      def url style_or_options = default_style, options = {}
        if style_or_options.is_a?(Hash)
          options.merge! style_or_options
          style = default_style
        else
          style = style_or_options
        end
        inline_opts = options[:cloudinary] || {}
        result = ::Cloudinary::Utils.cloudinary_url path(style), cloudinary_url_options(style, inline_opts)
        result.nil? ? super(nil) : result
      end

      def public_id style
        public_id_for_path(path style)
      end

      def public_id_for_path s
        s[0..-(File.extname(s).length + 1)]
      end

      def resource_type
        type = @options[:cloudinary_resource_type] || 'image'
        %w{image raw video audio}.include?(type.to_s) ? type.to_s : 'image'
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
        @cloudinary_credentials ||= parse_credentials(@options[:cloudinary_credentials] || find_default_config_path)
        @cloudinary_credentials
      end

      def parse_credentials creds
        creds = creds.respond_to?('call') ? creds.call(self) : creds
        creds = find_credentials(creds).stringify_keys
        env = Object.const_defined?(:Rails) ? Rails.env : nil
        (creds[env] || creds).symbolize_keys
      end

      private

      def cloudinary_url_options style_name, inline_opts={}
        url_opts     = @options[:cloudinary_url_options] || {}
        default_opts = url_opts[:default] || {}
        style_opts   = url_opts[:styles].try(:[], style_name) || {}

        default_opts[:resource_type] = resource_type

        options = {}
        [default_opts, style_opts, inline_opts].each do |opts|
          options.deep_merge!(opts) do |key, existing_value, new_value|
            new_value.try(:call, style_name, self) || new_value
          end
        end
        options.merge! default_opts
        options
      end

      def find_default_config_path
        config_path = Rails.root.join("config/cloudinary.yml")
        if File.exist? config_path
          return config_path
        else
          return Rails.root.join("config/cloudinary.yaml")
        end
      end

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
