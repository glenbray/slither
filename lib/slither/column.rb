require 'date'

class Slither
  class ParserError < RuntimeError; end

  class Column
    attr_reader :name, :length, :alignment, :type, :padding, :precision, :options, :transform

    def initialize(name, length, options = {})
      assert_valid_options(options)
      @name = name
      @length = length
      @options = options

      @alignment = options[:align] || :right
      @type = options[:type] || :string
      @padding = options[:padding] || :space
      @truncate = options[:truncate] || false
      # Only used with floats, this determines the decimal places
      @precision = options[:precision]
      @transform = options[:transform] # Proc for custom transformations of data
    end

    def unpacker
      "A#{@length}"
    end

    def parse(value)
      parsed_value = send("parse_#{@type.to_s}", value)
      @transform.nil? ? parsed_value : @transform.call(parsed_value)
    rescue
      raise ParserError, "Error parsing column ''#{name}'. The value '#{value}' could not be converted to type #{@type}: #{$!}"
    end

    def format(value)
      pad(formatter % to_s(value))
    rescue
      puts "Could not format column '#{@name}' as a '#{@type}' with formatter '#{formatter}' and value of '#{value}' (formatted: '#{to_s(value)}'). #{$!}"
    end

    def method_missing(method, *args)
      default_to_s(args[0])
    end

    private

    def parse_integer(value)
      value.to_i
    end

    def parse_float(value)
      value.to_f
    end

    def parse_money(value)
      value.parse_float(value)
    end

    def parse_money_with_implied_decimal(value)
      value.to_f / 100
    end

    def parse_string(value)
      value.strip
    end

    def parse_date(value)
      if @options[:format]
        Date.strptime(value, @options[:format])
      else
        Date.strptime(value)
      end
    end

    def formatter
      "%#{aligner}#{sizer}s"
    end

    def aligner
      @alignment == :left ? '-' : ''
    end

    def sizer
      (@type == :float && @precision) ? @precision : @length
    end

    # Manually apply padding. sprintf only allows padding on numeric fields.
    def pad(value)
      return value unless @padding == :zero
      matcher = @alignment == :right ? /^ +/ : / +$/
      space = value.match(matcher)
      return value unless space
      value.gsub(space[0], '0' * space[0].size)
    end

    def inspect
      "#<#{self.class} #{instance_variables.map{|iv| "#{iv}=>#{instance_variable_get(iv)}"}.join(', ')}>"
    end

    def to_s(value)
      result = send("#{@type}_to_s", value)
      validate_size result
    end

    def date_to_s(value)
      unless value.respond_to?(:strftime)
        value = value.to_time if value.respond_to?(:to_time)
      end
      if value.respond_to?(:strftime)
        if @options[:format]
          value.strftime(@options[:format])
        else
          value.strftime
        end
      else
        value.to_s
      end
    end

    def float_to_s(value)
      @options[:format] ? @options[:format] % value.to_f : value.to_f.to_s
    end

    def money_to_s(value)
      "%.2f" % value.to_f
    end

    def money_with_implied_decimal_to_s(value)
      "%d" % (value.to_f * 100)
    end

    def default_to_s(value)
      value.to_s
    end

    def assert_valid_options(options)
      unless options[:align].nil? || [:left, :right].include?(options[:align])
        raise ArgumentError, "Option :align only accepts :right (default) or :left"
      end
      unless options[:padding].nil? || [:space, :zero].include?(options[:padding])
        raise ArgumentError, "Option :padding only accepts :space (default) or :zero"
      end
    end

    def validate_size(result)
      # Handle when length is out of range
      if result.length > @length
        if @truncate
          start = @alignment == :left ? 0 : -@length
          result = result[start, @length]
        else
          raise Slither::FormattedStringExceedsLengthError,
            "The formatted value '#{result}' in column '#{@name}' exceeds the allowed length of #{@length} chararacters."
        end
      end
      result
    end
  end
end
