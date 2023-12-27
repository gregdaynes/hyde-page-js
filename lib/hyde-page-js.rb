require 'terser'
require 'digest'
require 'jekyll'

Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  Hyde::Page::Js.new(page).run
end

module Hyde
  module Page
    class Js
      VERSION = "0.2.0"
    end

    class GeneratedJsFile < Jekyll::StaticFile
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

    class Js
      @@config = {
        "source" => "assets/js",
        "destination" => "assets/js",
        "minify" => true,
        "enable" => true,
        "keep_files" => true,
        "dev_mode" => false
      }

      def initialize(page)
        @page = page
        @site = page.site
        @config = fetch_config

        if keep_files? && !dev_mode?
          @site.config.fetch("keep_files").push(destination)
        end
      end

      def run
        js = fetch_js(@page)
        layout = fetch_layout(fetch_layout_name(@page))
        results = parent_layout_js(layout, js).reverse

        data = concatenate_files(results)
        return if data == ""

        data = minify(data)
        return if data == ""

        generated_file = generate_file(results, data)

        # file already exists, so skip writing out the data to disk
        return unless @site.static_files.find { |static_file| static_file.name == generated_file.name }.nil?

        # place file data into the new file
        generated_file.file_contents = data

        # assign static file to list for jekyll to render
        @site.static_files << generated_file

        # assign to site.data.js_files for liquid output
        add_to_urls(generated_file.url)
      end

      private

      def add_to_urls(url)
        @site.data['js_files'] ||= []
        @site.data['js_files'].push(url)
      end

      def fetch_config
        @@config.merge(@site.config.fetch("hyde_page_js", {}))
      end

      def keep_files?
        @config.fetch("keep_files") == true
      end

      def dev_mode?
        @config.fetch("dev_mode") == true
      end

      def minify?
        @config.fetch("minify") == true
      end

      def destination
        @config.fetch("destination")
      end

      def source
        @config.fetch("source")
      end

      def qualified_source
        File.join(*[@site.source, source].compact)
      end

      def fetch_layout_name(obj_with_data, default = nil)
        obj_with_data.data.fetch('layout', default)
      end

      def fetch_js(obj_with_data, default = [])
        obj_with_data.data.fetch('js', []).reverse
      end

      def fetch_layout(layout_name, default = nil)
        @site.layouts.fetch(layout_name, default)
      end

      def mangle?
        if dev_mode?
          false
        elsif minify?
          true
        end
      end

      def parent_layout_js(layout, js)
        if layout.nil?
          return js.uniq.compact
        end

        layout_name = fetch_layout_name(layout)
        parent_layout = fetch_layout(layout_name)
        js = js.concat(fetch_js(layout))

        parent_layout_js(parent_layout, js)
      end

      def concatenate_files(files, data = [])
        files.each do |file_name|
          # tmp page required to handle anything with frontmatter/yaml header
          tmp_page = Jekyll::PageWithoutAFile.new(@site, nil, source, file_name)
          path = File.join([qualified_source, file_name])

          begin
            tmp_page.content = File.read(path)
            data.push(Jekyll::Renderer.new(@site, tmp_page).run)
          rescue
            Jekyll.logger.warn("Page JS Warning:", "Unable to find #{path}")
          end
        end

        data.join("\n")
      end

      def minify(data)
        converter_config = {mangle: mangle?, output: {comments: :copyright}}
        js_converter = Terser.new(converter_config)
        js_converter.compile(data)
      end

      def generate_file(files, data)
        file_name = generate_file_name(files, data)
        Hyde::Page::GeneratedJsFile.new(@site, source, file_name)
      end

      def generate_file_name(files, data, prefix: nil)
        file_names = [prefix]

        if dev_mode?
          files.each { |file| file_names.push(file.gsub(".js", "")) }
        end

        file_names.push(Digest::MD5.hexdigest(data)[0, 6])

        file_names.compact.join("-") + ".js"
      end
    end
  end
end
