require 'net/ssh'

module LxcSsh
  class Connection

    attr_reader :manager

    # Initializes the connection
    def initialize
      @session = nil
      @manager = nil
      @lxc_version = nil
      @lxc_path = nil
    end

    # Connects to the host system via ssh and authenticates by
    # either public key or password authentication
    #
    # @param hostname [String] SSH Hostname
    # @param username [String] SSH Username
    # @param password [String] SSH Password
    # @param lxc_path [String] LXC installation path (default: /usr)
    def connect(hostname, username, password, lxc_path = '/usr')
      if @password.nil?
        # pubkey
        @session = Net::SSH.start(hostname, username)
      else
        @session = Net::SSH.start(hostname, username, password)
      end

      @lxc_path = lxc_path
      @lxc_version = obtain_version
      @manager = self.init_manager
    end

    # Obtains the version number of the lxc installation
    #
    # @return string
    def obtain_version
      output = @session.exec! @lxc_path + "/bin/lxc-start --version"

      output.strip
    end

    # Initializes the lxc manager object
    def init_manager
      if @lxc_version.nil?
        raise 'no lxc version set, please detect and set the lxc version using detect_lxc_version'
      end

      @manager = LxcSsh::Manager.new(@session, @lxc_version, @lxc_path)
    end
  end
end
