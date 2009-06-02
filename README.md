# RobustThread

This module allows for the creation of a thread that will not simply die when
the process dies. Instead, it joins all RobustThreads in Ruby's exit handler.

## Usage:

    require 'rubygems'
    require 'robustthread'

    RobustThread.new(args) do |x, y|
      do_something(x, y)
    end
