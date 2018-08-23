require 'tmpdir'

# :nodoc:
class Replr
  attr_reader :arguments

  def start
    @arguments = ARGV.map { |argument| argument.downcase.strip }

    check_docker!
    check_argument_length!
    check_stack!

    workdir = Dir.mktmpdir
    Dir.chdir(workdir)
    puts library_file_with(libraries)
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

  def puts_error(string)
    STDERR.puts(string)
  end
end
