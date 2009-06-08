# Author:: Jared Kuolt (mailto:me@superjared.com)
# Copyright:: Copyright (c) 2009 Jared Kuolt
# License:: MIT License
require 'logger'

class RobustThread
  # The Thread object, brah
  attr_reader :thread
  # If the Thread takes a poopie...
  attr_reader :exception
  # An identifier
  attr_accessor :label

  # Create a new RobustThread (see README)
  def initialize(opts={}, &block)
    self.class.send :init_exit_handler
    args = opts[:args] or []
    @thread = Thread.new(*args) do |*targs|
      begin
        block.call(*targs)
      rescue => e
        @exception = e
        self.class.send :handle_exception, e
      end
      self.class.log "#{self.label.inspect} exited cleanly"
    end
    self.label = opts[:label] || @thread.inspect
    self.class.group << self
  end

  ## Class methods and attributes
  class << self
    attr_accessor :logger, :say_goodnight, :exit_handler_initialized

    # Logger object (see README)
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    # Simple log interface
    def log(msg, level=:info)
      self.logger.send level, "#{self}: " + msg
    end

    # The collection of RobustThread objects
    def group
      @group ||= [] 
    end

    # Loop an activity and exit it cleanly (see README)
    def loop(opts={}, &block)
      sleep_seconds = opts.delete(:seconds) || 2
      self.new(opts) do |*args|
        Kernel.loop do
          break if self.say_goodnight
          block.call(*args)
          sleep sleep_seconds
        end
      end
    end

    # Set exception handler
    def exception_handler(&block)
      unless block.arity == 1
        raise ArgumentError, "Bad arity for exception handler. It may only accept a single argument"
      end
      @exception_handler = block
    end

    private
    # Calls exception handler if set (see RobustThread.exception_handler)
    def handle_exception(exc)
      if @exception_handler.is_a? Proc
        @exception_handler.call(exc)
      else
        log("Unhandled exception:\n#{exc.message} " \
            "(#{exc.class}): \n\t#{exc.backtrace.join("\n\t")}", :error)
      end
    end

    # Sets up the exit_handler unless exit_handler_initialized
    def init_exit_handler
      return if self.exit_handler_initialized
      self.say_goodnight = false
      at_exit do
        self.say_goodnight = true
        begin
          self.group.each do |rt|
            log "waiting on #{rt.label.inspect}"
            rt.thread.join
          end
          log "exited cleanly"
        rescue Interrupt
          log "prematurely killed by interrupt!", :error
        end
      end
      self.exit_handler_initialized = true
    end
  end
end
