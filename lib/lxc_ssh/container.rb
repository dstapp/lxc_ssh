module LxcSsh
  class Container

    attr_accessor :name,
                  :state,
                  :pid,
                  :ip,
                  :memory_usage,
                  :memory_limit,
                  :cpu_shares,
                  :cpu_usage

    # Checks if the container is running
    #
    # @return [Boolean]
    def running?
      @state == 'RUNNING'
    end

    # Checks if the container is frozen
    #
    # @return [Boolean]
    def frozen?
      @state == 'FROZEN'
    end

    # Checks if the container is stopped
    #
    # @return [Boolean]
    def stopped?
      !running? && !frozen?
    end

  end
end