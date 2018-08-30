require_relative '../../../replr'
require_relative '../../process_runner'

require 'json'

# :nodoc:
module Replr
  module Stack
    module Node
      # Creates a Ruby REPL using docker for a stack and libraries combo
      class REPLMaker < Replr::Stack::REPLMaker
        private

        def set_library_file_name
          @library_file_name = 'package.json'
        end

        # It's optional to set a bootstrap file
        def set_bootstrap_file_name
          @bootstrap_file_name = 'replr-bootstrap.js'
        end

        def set_template_dir
          @template_dir = __dir__
        end

        def set_filter_lines_for_install
          @filter_matching_lines_for_install = [/packages/i, /download/i]
          @filter_not_matching_lines_for_install = []
        end

        def library_file_with(libraries)
          package_file = {
            name: "@#{docker_image_tag}",
            version: '1.0.0',
            description: 'Replr for Node',
            author: 'Vishnu Gopal <vishnugopal@users.noreply.github.com>',
            repository: 'https://github.com/vishnugopal/replr',
            license: 'MIT',
            scripts: {
              start: 'node replr-bootstrap.js'
            }
          }
          dependencies = {}
          libraries.each do |library|
            if library.include?(':')
              library, version = library.split(':')
              dependencies[library] = version
            else
              dependencies[library] = '*'
            end
          end
          package_file[:dependencies] = dependencies
          package_file.to_json
        end
      end
    end
  end
end
