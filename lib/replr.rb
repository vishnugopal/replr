class Replr
  attr_reader :arguments

  def start
    @arguments = ARGV.map { |argument| argument.downcase.strip }

    unless arguments.length > 1
      puts_error "Usage: replr <stack> <libraries...>"
      exit
    end

    unless "ruby" == arguments[0]
      puts_error "Only supports ruby for now"
      exit
    end

    unless system("which docker >/dev/null")
      puts_error "Needs docker installed & in path to work."
      exit
    end

    extract_libraries
  end

  private
  def extract_libraries
    libraries = arguments[1..-1]
    puts gemfile_for_libraries(libraries)
  end

  def gemfile_for_libraries(libraries)
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
