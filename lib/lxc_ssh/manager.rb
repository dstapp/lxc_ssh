module LxcSsh
  class Manager

    # Initializes the lxc manager by creating an instance of the version-specific
    # lxc manager for the detected version
    #
    # @param session [SSH::Connection::Session] ssh session
    # @param lxc_version [String] lxc version string
    # @param lxc_path [String] lxc installation path
    def initialize(session, lxc_version, lxc_path)
      @lxc_path = lxc_path
      @specific_manager = nil

      # LXC APIs mac change in the future, therefore a version specific adapter
      # must be used
      if    Gem::Version.new(lxc_version) >= Gem::Version.new('1.0')
        @specific_manager = LxcSsh::SpecificManager10.new(session, lxc_path)
      # other version checks go here
      else
        raise 'lxc versions < 1.0 are not supported'
      end
    end

    # Returns an array of lxc containers
    #
    # @return [Array]
    def container_names
      @specific_manager.container_names
    end

    # Returns an array containing objects with container metadata
    #
    # @return [Array]
    def containers
      @specific_manager.containers
    end

    # Returns a LxcSsh::ContainerConfig object for the container name
    #
    # @return [LxcSsh::ContainerConfig]
    def container_config(name)
      @specific_manager.container_config name
    end

    # Returns an LxcSsh::Container object for the given container name
    #
    # @return [LxcSsh::Container]
    def container(name)
      @specific_manager.get_container_obj name
    end

    # Writes the config file contents back to the container config
    #
    # @param container_name [String] the container to use
    # @param config [String] configuration string to save
    def write_config(name, config)
      @specific_manager.write_config name, config
    end

    # Returns an array containing all templates
    #
    # @todo check path
    #
    # @return [Array]
    def template_names
      @specific_manager.template_names
    end

    # Returns the template help text for a given template name
    #
    # @param template_name [String] template to use (without 'lxc-'-prefix)
    # @return [String]
    def template_help(name)
      @specific_manager.template_help name
    end

    # Creates a container with the default configuration and additional template options
    # and returns the output as a string
    #
    # @param name [String] container name
    # @param template [String] template name (without 'lxc-'-prefix)
    # @param template_options [String] additional template options
    #
    # @return [String]
    def create_container(name, template, template_options = nil)
      @specific_manager.create_container name, template, template_options
    end

    # Starts a container with the given name
    #
    # @param name [String] container name
    # @return [Boolean]
    def start_container(name)
      @specific_manager.start_container name
    end

    # Stops a container
    #
    # @param name [String] container name
    # @return [Boolean]
    def stop_container(name)
      @specific_manager.stop_container name
    end

    # Destroys a container with the given name
    #
    # @param name [String] container name
    # @return [Boolean]
    def destroy_container(name)
      @specific_manager.destroy_container name
    end

  end
end