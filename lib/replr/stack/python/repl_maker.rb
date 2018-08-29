require_relative '../../../replr'
require_relative '../../process_runner'

require_relative '../../../replr'
require_relative '../../process_runner'

# :nodoc:
module Replr
  module Stack
    module Python
      # Creates a Python REPL using docker for a stack and libraries combo
      class REPLMaker < Replr::Stack::REPLMaker
        private

        def set_library_file_name
          @library_file_name = 'requirements.txt'
        end

        def set_template_dir
          @template_dir = __dir__
        end

        def set_filter_lines_for_install
          @filter_matching_lines_for_install = [/pip/i]
          @filter_not_matching_lines_for_install = [/\.cache/i]
        end

        def library_file_with(libraries)
          requirements = ''
          libraries.each do |library|
            if library.include?(':')
              library, version = library.split(':')
              requirements << "#{library}==#{version}\n"
            else
              requirements << "#{library}\n"
            end
          end
          requirements
        end
      end
    end
  end
end
