# This module allows for the creation of a thread that will not simply die when
# the process dies. Instead, it joins all RobustThreads in Ruby's exit handler.
#
# Author:: Jared Kuolt (mailto:me@superjared.com)
# Copyright:: Copyright (c) 2009 Jared Kuolt
# License:: MIT License

class RobustThread
  # The Thread object, brah
  attr_reader :thread
  # If the Thread takes a poopie...
  attr_reader :exception
  @@exit_handler_initialized = false
  @@exception_handler = nil
  # Usage:
  #
  #   rt = RobustThread.new(args) do |x, y|
  #     do_something(x, y)
  #   end
  #
  # If necessary, you can access the actual thread from the +RobustThread+
  # object via its +thread+ attribute.
  #
  #   rt.thread
  #   => #<Thread:0x7fa1ea57ff88 run>
  def initialize(*args, &block)
    RobustThread.init_exit_handler
    @thread = Thread.new(*args) do |*targs|
      begin
        block.call(*targs)
      rescue => e
        @exception = e
        RobustThread.handle_exception(e)
      end
    end
    @thread[:real_ultimate_power] = true
  end

  # Set exception handler:
  #
  #   RobustThread.exception_handler do |exception|
  #     handle_exception(exception)
  #   end
  def RobustThread.exception_handler(&block)
    unless block.arity == 1
      raise ArgumentError, "Bad arity for exception handler. It may only accept a single argument"
    end
    @@exception_handler = block
  end

  private
  # Sets up the exit_handler unless @@exit_handler_initialized
  def RobustThread.init_exit_handler
    return if @@exit_handler_initialized
    at_exit do
      Thread.list.each do |thread|
        thread.join if thread[:real_ultimate_power]
      end
    end
    @@exit_handler_initialized = true
  end

  # Calls exception handler if set (see RobustThread.exception_handler)
  def RobustThread.handle_exception(exception)
    return unless @@exception_handler
    @@exception_handler.call(exception)
  end
end
