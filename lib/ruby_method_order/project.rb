require 'csv'

module RubyMethodOrder
  class Project
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
      abort "Not a git repo: #{@path}" unless File.directory? File.join(@path, '.git')
      abort "Not a ruby project: #{@path}" unless ruby_files.any?
    end

    def ruby_files
      @ruby_files ||= Dir.glob "#{path}/**/*.rb"
    end

    def sourcefiles
      @files = ruby_files.map { |path| Sourcefile.new(path) }
    end

    def name
      File.basename path
    end

    # in kb
    def size
      @size ||= `du -sk #{path}`[/\A\d+/].to_i
    end

    def test_ratio
      @ratio ||= begin
        test_quantity = `du -sk #{path}/{test,spec} 2> /dev/null`.each_line.map { |line| line[/\A\d+/].to_i }.inject(:+) || 0
        (test_quantity.to_f / size).round(6).tap{|q|puts path}
      end
    end

    # in days
    def age
      (Time.now.to_i - `cd #{path}; git log --reverse --pretty=format:%at | head -1`.to_i) / 3600 / 24
    end

    def print_csv
      csv = CSV.new($stdout)
      sourcefiles.each do |sourcefile|
        csv << [name, size, test_ratio, age, File.basename(sourcefile.path), sourcefile.superclass, sourcefile.method_order_class, sourcefile.method_order.join(' < ')]
      end
    end
  end
end
