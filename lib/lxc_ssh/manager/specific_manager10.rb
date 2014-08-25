module LxcSsh
  class SpecificManager10

    # Initializes the manager
    #
    # @param session [SSH::Connection::Session] ssh session
    # @param lxc_path [String] lxc installation path
    def initialize(session, lxc_path)
      @session = session
      @lxc_path = lxc_path
    end

    # Returns an array of lxc containers
    #
    # @return [Array]
    def container_names
      result = @session.exec! @lxc_path + '/bin/lxc-ls'

      result.lines.map(&:strip).uniq
    end

    # Returns an array containing objects with container metadata
    #
    # @return [Array]
    def containers
      containers = []

      container_names.each do |name|
        containers << get_container_obj(name)
      end

      containers
    end

    # Returns an LxcSsh::Container object for the given container name
    #
    # @return [LxcSsh::Container]
    def get_container_obj(name)
      container = Container.new
      container.name = name

      info = info(name)
      container.pid = info.pid
      container.state = info.state

      container.memory_usage = run_cmd("lxc-cgroup", name, "memory.usage_in_bytes").strip.to_i
      container.memory_limit = run_cmd("lxc-cgroup", name, "memory.limit_in_bytes").strip.to_i
      container.cpu_shares = run_cmd("lxc-cgroup", name, "cpu.shares").strip.to_i
      container.cpu_usage = cpu_usage name
      container.ip = ip_addr name

      container
    end

    # Returns a LxcSsh::ContainerConfig object for the container name
    #
    # @return [LxcSsh::ContainerConfig]
    def container_config(name)
      contents = config_contents name

      ContainerConfig.new contents
    end

    # Writes the config file contents back to the container config
    #
    # @todo verify function
    # @todo escape contents variable
    #
    # @param container_name [String] the container to use
    # @param config [String] configuration string to save
    def write_config(container_name, config)
      if !config.kind_of?(ContainerConfig)
        raise ArgumentError, "config must be a instance of ContainerConfig"
      end

      contents = config.config_contents

      @session.exec! "echo -e '" + contents + "' > " + config_path(container_name)
    end

    # Returns an array containing all templates
    #
    # @todo check path
    #
    # @return [Array]
    def template_names
      output = @session.exec! "ls -1 " + @lxc_path + "/share/lxc/templates/"
      output.gsub! 'lxc-', ''

      result = output.lines.map(&:strip).uniq

      result
    end

    # Returns the template help text for a given template name
    #
    # @param template_name [String] template to use (without 'lxc-'-prefix)
    # @return [String]
    def template_help(template_name)
      output = run_cmd("lxc-create", nil, "-t lxc-#{template_name} -h")

      output
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
      args = "-t #{template}"

      if template_options.nil? == false
        args += " -- #{template_options}"
      end

      output = run_cmd("lxc-create", name, args)

      output
    end

    # Starts a container with the given name
    #
    # @param name [String] container name
    # @return [Boolean]
    def start_container(name)
      output = run_cmd("lxc-start", name, '-d')

      output.nil?
    end

    # Stops a container
    #
    # @param name [String] container name
    # @return [Boolean]
    def stop_container(name)
      output = run_cmd("lxc-stop", name)

      output.nil?
    end

    # Destroys a container with the given name
    #
    # @param name [String] container name
    # @return [Boolean]
    def destroy_container(name)
      output = run_cmd("lxc-destroy", name)

      output.nil?
    end

    protected
      # Executes a lxc command
      #
      # @param lxc_binary [String] lxc binary name
      # @param container_name [String] container name (if needed, otherwise nil)
      # @param params [String] additional parameter string to append
      # @return [String]
      def run_cmd(xlc_binary, container_name = nil, params = nil)
        cmd = @lxc_path + '/bin/' + xlc_binary

        if container_name.nil? == false
          cmd += ' -n ' + container_name
        end

        cmd += ' '

        if params.nil? == false
          cmd += params
        end

        @session.exec!(cmd)
      end

      # Loads the lxc container path using lxc-config
      #
      # @return [String]
      def container_path(name)
        output = run_cmd("lxc-config", nil, "lxc.lxcpath").strip

        "#{output}/#{name}"
      end

      # Returns the config file path for a given container
      #
      # @return [String]
      def config_path(name)
        container_path(name) + '/config'
      end

      # Obtains the contents of a container config file
      #
      # @return [String]
      def config_contents(name)
        @session.exec! 'cat ' + config_path(name)
      end

      # Returns the containers current cpu usage
      #
      # @return [String]
      def cpu_usage(name)
        result = run_cmd("lxc-cgroup", name, "cpuacct.usage").strip

        result
      end

      # Returns the containers ip address
      #
      # @todo what happens if multiple ip addresses are configured
      #
      # @param name [String] container name
      # @return [String]
      def ip_addr(name)
        output = run_cmd("lxc-info", name, "-i")

        if output.nil?
          return nil
        end

        result = output.scan(/^IP:\s+([0-9.]+)$/).flatten

        result.first.nil? || result.first.empty? ? nil : result.first
      end

      # Returns a LxcSsh::ContainerInfo object containing the most essential information.
      #
      # @param name [String] container name
      # @return [LxcSsh::ContainerInfo]
      def info(name)
        output = run_cmd("lxc-info", name)
        result = output.scan(/^State:\s+([\w]+)|PID:\s+(-?[\d]+)$/).flatten

        ci = ContainerInfo.new
        ci.state = result.first
        ci.pid = result.last

        ci
      end

  end
end