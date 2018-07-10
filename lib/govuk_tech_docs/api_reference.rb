require 'openapi3_parser'

module GovukTechDocs
  class ApiReference
    def initialize
      # Need to grab the config object.
      @config = YAML.load_file('config/tech-docs.yml')

      # If no api path then just return.
      if @config["api_path"].to_s.empty?
        # @TODO Throw a middleman error?
        return
      end

      # Load api file and set existence flag.
      if File.exists?(@config["api_path"])
        @api_parser = true

        @document = Openapi3Parser.load_file(@config["api_path"])
      else
        # @TODO Throw a middleman error?
        @api_parser = false
      end
    end

    def api(text)
      if @api_parser == true

        map = {
            "api&gt;" => ""
        }

        # @TODO if there is just api> then print everything

        regexp = map.map {|k, _| Regexp.escape(k)}.join("|")

        if md = text.match(/^<p>(#{regexp})/)
          key = md.captures[0]
          text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

          # Strip paragraph tags from text
          text = text.gsub(/<\/?[^>]*>/, "")
          text = text.strip

          # Call api parser on text
          api_data = @document.paths[text]

          # @TODO This should be a template file.
          return <<-EOH.gsub(/^ {8}/, "")
          <div class="api-builder">
            <pre>#{text}
              #{api_data.node_data}
            </pre>
          </div>
          EOH
        else
          return text
        end

      else
        return text
      end
    end
  end
end