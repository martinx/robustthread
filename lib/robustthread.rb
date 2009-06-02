# This module allows for the creation of a thread that will not simply die when
# the process dies. Instead, it joins all RobustThreads in Ruby's exit handler.
#
# Author:: Jared Kuolt (mailto:me@superjared.com)
# Copyright:: Copyright (c) 2009 Jared Kuolt
# License:: MIT License

module RobustThread
  # Usage:
  #
  #   RobustThread.new(args) do |x, y|
  #     do_something(x, y)
  #   end
  #
  def new(*args, &block)
    thread = Thread.new(*args) do |*targs|
      block.call(*targs)
    end
    thread[:real_ultimate_power] = true
    thread
  end

  module_function :new
end

# We define the BEGUN constant only after we've setup the exit handler
unless defined? RobustThread::BEGUN
  at_exit do
    Thread.list.each do |thread|
      thread.join if thread[:real_ultimate_power]
    end
  end
  RobustThread::BEGUN = true
end
