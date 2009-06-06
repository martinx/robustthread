# Author:: Jared Kuolt (mailto:me@superjared.com)
# Copyright:: Copyright (c) 2009 Jared Kuolt
# License:: MIT License
#
# This module allows for the creation of a thread that will not simply die when
# the process dies. Instead, it joins all RobustThreads in Ruby's exit handler.
#
# Usage:
#
#   rt = RobustThread.new(args) do |x, y|
#     do_something(x, y)
#   end
#
# If necessary, you can access the actual thread from the RobustThread
# object via its +thread+ attribute.
#
#   rt.thread
#   => #<Thread:0x7fa1ea57ff88 run>
#
# By default, RobustThread uses a Logger that defaults itself to STDOUT. You
# can change this by assigning the +logger+ class attribute to a different 
# Logger object:
#
#   RobustThread.logger = Logger.new(STDERR)
#
# Since Threads usually eat exceptions, RobustThread allows for a simple global
# exception handler:
#
#   RobustThread.exception_handler do |exception|
#     # Handle your exceptions here
#   end
#
# If no handler is assigned, the exception traceback will be piped into the
# logger as an error message.
require 'logger'

class RobustThread
  # The Thread object, brah
  attr_reader :thread
  # If the Thread takes a poopie...
  attr_reader :exception

  # Create a new RobustThread (see usage)
  def initialize(*args, &block)
    self.class.send :init_exit_handler
    @thread = Thread.new(*args) do |*targs|
      begin
        block.call(*targs)
      rescue => e
        @exception = e
        self.class.send :handle_exception, e
      end
    end
    @thread[:real_ultimate_power] = true
  end

  ## Class methods and attributes
  class << self
    attr_accessor :logger, :exit_handler_initialized

    # Logger object (see usage)
    def logger
      @logger ||= Logger.new(STDOUT)
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
        self.logger.error("RobustThread: Unhandled exception:\n#{exc.message} " \
                          "(#{exc.class}): \n\t#{exc.backtrace.join("\n\t")}")
      end
    end

    # Sets up the exit_handler unless exit_handler_initialized
    def init_exit_handler
      return if self.exit_handler_initialized
      at_exit do
        begin
          Thread.list.each do |thread|
            if thread[:real_ultimate_power]
              logger.info "RobustThread waiting on #{thread.inspect}"
              thread.join
            end
          end
          logger.info "RobustThread exited cleanly"
        rescue Interrupt
          logger.error "RobustThread(s) prematurely killed by interrupt!"
        end
      end
      self.exit_handler_initialized = true
    end
  end
end
