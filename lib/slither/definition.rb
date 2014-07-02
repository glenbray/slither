class Slither
  class Definition
    attr_reader :sections, :templates, :options

    def initialize(options = {})
      @sections = []
      @templates = {}
      @options = { :align => :right, :by_bytes => true }.merge(options)
    end

    def section(name, options = {}, &block)
      raise( ArgumentError, "Reserved or duplicate section name: '#{name}'") if
        reserved_name?(name) || section_has_name?(name)

      section = Slither::Section.new(name, @options.merge(options))
      section.definition = self
      yield(section)
      @sections << section
      section
    end

    def template(name, options = {}, &block)
      section = Slither::Section.new(name, @options.merge(options))
      yield(section)
      @templates[name] = section
    end

    def method_missing(method, *args, &block)
      section(method, *args, &block)
    end

    private

    def reserved_name?(name)
      Section::RESERVED_NAMES.include?(name)
    end

    def section_has_data?
      @sections.size > 0
    end

    def section_has_name?(name)
      section_has_data? && @sections.map{ |s| s.name }.include?( name )
    end

  end
end