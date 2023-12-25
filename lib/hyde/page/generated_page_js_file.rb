module Hyde
  module Page
    # Alternative class for jekyll's static files
    # this allows the creation of files without a source file

    class GeneratedPageJsFile < Jekyll::StaticFile
      attr_accessor :file_contents
      attr_reader :generator

      def initialize(site, dir, name)
        @site = site
        @dir = dir
        @name = name
        @relative_path = File.join(*[@dir, @name].compact)
        @extname = File.extname(@name)
        @type = @collection&.label&.to_sym
        @generator = "hyde-page-js"
      end

      def write(dest)
        dest_path = destination(dest)
        return false if File.exist?(dest_path)

        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.rm(dest_path) if File.exist?(dest_path)

        File.open(dest_path, "w") do |output_file|
          output_file << file_contents
        end

        true
      end
    end
  end
end
