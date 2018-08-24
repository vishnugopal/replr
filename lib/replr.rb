require 'tmpdir'
require 'open3'

# :nodoc:
class Replr
  attr_reader :arguments, :workdir, :docker_image_tag

  def start
    @arguments = ARGV.map { |argument| argument.downcase.strip }

    check_docker!
    check_argument_length!
    check_stack!

    @workdir = Dir.mktmpdir
    @docker_image_tag = "replr/ruby-#{libraries.join('-')}"

    copy_library_file
    copy_docker_file
    initialize_docker_repl
  end

  private

  def check_argument_length!
    if arguments.empty?
      puts_error 'Usage: replr <stack> <libraries...>'
      exit
    end
  end

  def check_stack!
    unless arguments[0] == 'ruby'
      puts_error 'Only supports ruby for now'
      exit
    end
  end

  def check_docker!
    unless system('which docker >/dev/null')
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

  def libraries
    arguments[1..-1]
  end

  def library_file_with(libraries)
    gemfile = "source 'https://rubygems.org/'\n"
    libraries.each do |library|
      gemfile << "gem '#{library}'\n"
    end
    gemfile
  end

  def initialize_docker_repl
    Dir.chdir(workdir) do
      build_command = "docker build -t #{docker_image_tag} ."
      run_command = "docker run --rm -it #{docker_image_tag}"
      matching = Regexp.union([/upgrading/i, /installing/i, /gem/i])
      not_matching = Regexp.union([/step/i])
      execute_filtered_process(build_command, matching,
                               not_matching) do |stderr, process_thread|
        execute_command_if_not_stderr(run_command, stderr, process_thread)
      end
    end
  end

  # Runs *command* and only prints those lines that match
  # *matching_regex* and doesn't match *not_matching_regex*. After
  # execution, it passes *stderr* and the waiting *process_thread*
  # to a block.
  def execute_filtered_process(command, matching_regex,
                               not_matching_regex, &_block)
    Open3.popen3(command) do |_stdin, stdout, stderr, process_thread|
      stdout.each_line do |outline|
        if outline.match(matching_regex) &&
           !outline.match(not_matching_regex)
          puts outline
        end
      end

      # Yield to block to process next set of commands or handle stderr
      yield(stderr, process_thread)
    end
  end

  # Executes *new_command* if the previous *process_thread* had a
  # non-zero return.
  def execute_command_if_not_stderr(new_command, stderr, process_thread)
    outerror = stderr.read.chomp
    if process_thread.value.to_i.zero?
      system(new_command)
    else
      STDERR.puts outerror
    end
  end
end
