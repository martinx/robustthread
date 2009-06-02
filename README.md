# RobustThread

This module allows for the creation of a thread that will not simply die when
the process dies. Instead, it joins all RobustThreads in Ruby's exit handler.

## Installation

    gem sources -a http://gems.github.com
    sudo gem install JaredKuolt-robustthread

## Usage:

    require 'rubygems'
    require 'robustthread'

    RobustThread.new(args) do |x, y|
      do_something(x, y)
    end
