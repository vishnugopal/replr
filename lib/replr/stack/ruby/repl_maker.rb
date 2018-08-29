require_relative '../../../replr'
require_relative '../../process_runner'

# :nodoc:
module Replr
  module Stack
    module Ruby
      # Creates a Ruby REPL using docker for a stack and libraries combo
      class REPLMaker < Replr::Stack::REPLMaker
        private

        def set_library_file_name
          @library_file_name = 'Gemfile'
        end

        # It's optional to set a bootstrap file
        def set_bootstrap_file_name
          @bootstrap_file_name = 'replr-bootstrap.rb'
        end

        def set_template_dir
          @template_dir = __dir__
        end

        def set_filter_lines_for_install
          @filter_matching_lines_for_install = [/gem/i]
          @filter_not_matching_lines_for_install = []
        end

        def library_file_with(libraries)
          gemfile = "source 'https://rubygems.org/'\n"
          libraries.each do |library|
            if library.include?(':')
              library, version = library.split(':')
              gemfile << "gem '#{library}', '#{version}'\n"
            else
              gemfile << "gem '#{library}'\n"
            end
          end
          gemfile
        end
      end
    end
  end
end
