require_relative '../replr'
require_relative 'argument_processor'
require_relative 'process_runner'

require 'tmpdir'
require 'open3'

# :nodoc:
module Replr
  # Creates a REPL using template Dockerfiles & libraries
  class REPLMaker
    attr_reader :argument_processor, :process_runner
    attr_reader :libraries, :workdir

    def start
      @argument_processor = Replr::ArgumentProcessor.new
      @process_runner = Replr::ProcessRunner.new

      @libraries = argument_processor.arguments[1..-1].sort!
      @workdir = Dir.mktmpdir

      check_docker!
      execute_processsed_arguments!
    end

    private

    def docker_image_tag
      normalized_library_string = libraries.map do |library|
        library.gsub(':', '-v')
      end.join('-')
      "replr/ruby-#{normalized_library_string}"
    end

    def execute_processsed_arguments!
      if argument_processor.arguments[0] == 'prune'
        execute_prune_command
      else
        copy_library_file
        copy_docker_file
        initialize_docker_repl
      end
    end

    def execute_prune_command
      prune_command = %q(docker images -a |  grep "replr/" | awk '{print $3}' | xargs docker rmi)
      process_runner.execute_command(prune_command)
    end

    def check_docker!
      unless process_runner.process_exists?('docker')
        puts_error 'Needs docker installed & in path to work.'
        exit
      end
    end

    def puts_error(string)
      STDERR.puts(string)
    end

    def copy_library_file
      Dir.chdir(workdir) do
        File.open('Gemfile', 'w') do |f|
          f.write(library_file_with(libraries))
        end
      end
    end

    def copy_docker_file
      docker_file = "#{__dir__}/Dockerfile"
      bootstrap_file = "#{__dir__}/replr-bootstrap.rb"
      FileUtils.cp(docker_file, workdir)
      FileUtils.cp(bootstrap_file, workdir)
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

    def initialize_docker_repl
      Dir.chdir(workdir) do
        build_command = "docker build -t #{docker_image_tag} ."
        run_command = "docker run --rm -it #{docker_image_tag}"
        matching = Regexp.union([/upgrading/i, /installing/i, /gem/i])
        not_matching = Regexp.union([/step/i])
        process_runner.execute_filtered_process(build_command, matching,
                                                not_matching) do |stderr, process_thread|
          process_runner.execute_command_if_not_stderr(run_command, stderr, process_thread)
        end
      end
    end
  end
end
