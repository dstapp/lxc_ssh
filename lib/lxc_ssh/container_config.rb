module LxcSsh
  class ContainerConfig

    # Loads the configuration object with the config files' content
    #
    # @param data [String] config file contents
    def initialize(data)
      @content = parse(data)
    end

    # Loads the configuration object with the config files' content
    #
    # @param data [String] config file contents
    # @return [Hash]
    def parse(data)
      items = {}

      # only lines starting with 'lxc.'
      lines = data.lines.map(&:strip).select do |line|
        line.start_with?('lxc.')
      end

      # process lines
      lines.each do |line|
        key, value = line.split('=').map(&:strip)

        if items.key?(key) == false
          items[key] = []
        end

        items[key] << value
      end

      items.each_pair do |key, val|
        if val.length == 1
          items[key] = val.first
        end
      end

      items
    end

    # Array-style accessor (getter)
    #
    # @param key [String] key of the hash
    # @return [Object]
    def [](key)
      if key.kind_of?(String) == false
        raise ArgumentError, 'key must be a string'
      end

      @content[key]
    end

    # Array-style accessor (setter)
    #
    # @param key [String] key of the hash
    # @param val [Object] value to set
    def []=(key, val)
      @content[key] = val
    end

    # Generates a config string from the current object context
    #
    # @return [Hash]
    def config_contents
      lines = []

      @content.each_pair do |key, value|
        if value.class == Array
          # multiple values assigned for a single key, order is important!
          lines << value.map do |val|
            key + ' = ' + val
          end
        else
          line = key + ' = ' + value
          lines << line
        end
      end

      lines.join('\n')
    end

  end
end