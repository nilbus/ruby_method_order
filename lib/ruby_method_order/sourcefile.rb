require 'ruby_parser'
require 'scanf'

module RubyMethodOrder
  class Sourcefile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def superclass
      method_order unless @superclass

      @superclass ||= :no_class
    end

    def method_order
      @order ||= begin
        # parts = [:initialize, :class, :instance]
        parts = []
        source = File.read path
        tree = Sexp.new(RubyParser.new.parse(source))
        tree.each_of_type(:class) do |klass|
          class_name = klass[1]
          @superclass = (klass[2] ? klass[2][1] : :Object)
          klass.each do |sexp|
            next unless Sexp === sexp
            if sexp_defines_initialize? sexp
              parts << :initialize
            elsif sexp_defines_instance_method? sexp
              parts << :instance
            elsif sexp_defines_class_method?(sexp) || sexp_defines_class_methods?(sexp, class_name)
              parts << :class
            end
          end
          break # ignore subsequent classes, if any, since we're picking an order for the file
        end

        contiguous_uniq(parts)
      end
    rescue Racc::ParseError
      [:parse_error]
    end

    def method_order_class
      if method_order.size == 0
        'none'
      elsif method_order.uniq.size != method_order.size
        'mixed'
      else
        method_order.join ' < '
      end
    end

  private

    def contiguous_uniq(array)
      array.chunk { |n| n }.map { |x| x.first }
    end

    def sexp_defines_initialize?(sexp)
      sexp.sexp_type == :defn && sexp[1] == :initialize
    end

    def sexp_defines_instance_method?(sexp)
      sexp.sexp_type == :defn
    end

    def sexp_defines_class_method?(sexp)
      sexp.sexp_type == :defs && sexp[1] == Sexp.new(:self)
    end

    def sexp_defines_class_methods?(sexp, class_name)
      if (defines_metaclass = sexp.sexp_type == :sclass)
        if (defines_my_metaclass = sexp[1] == Sexp.new(:self) || sexp[1] == Sexp.new(:const, class_name))
          sexp_defines_instance_methods? sexp[2..-1]
        end
      end
    end

    def sexp_defines_instance_methods?(sexp)
      sexp.find do |inner_sexp|
        Sexp === inner_sexp && inner_sexp.sexp_type == :defn # def
      end
    end
  end
end
