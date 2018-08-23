require 'tmpdir'

# :nodoc:
class Replr
  attr_reader :arguments, :workdir

  def start
    @arguments = ARGV.map { |argument| argument.downcase.strip }

    check_docker!
    check_argument_length!
    check_stack!

    @workdir = Dir.mktmpdir

    copy_library_file
    copy_docker_file
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
    FileUtils.cp(docker_file, workdir)
    puts workdir
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
end
