# RobustThread

This class allows for the creation of a thread that will not simply die when
the process dies. Instead, it joins all `RobustThread`s in Ruby's exit handler.
Additionally, setting exception handlers is trivial.

## Installation

    sudo gem install robustthread

## Usage:

Create threads as RobustThread objects, and you can access the thread from the
`thread` attribute, the exception (if any has been called up until that point)
from its `exception` attribute.

    require 'rubygems'
    require 'robustthread'

    RobustThread.new(args) do |x, y|
      do_something(x, y)
    end

## Exception handlers

Explicitly creating a global exception handler is simple:

    RobustThread.exception_handler do |exception|
      handle_exception(exception)
    end

If you dont set a handler, the exception will be silently caught and is 
accessible from the `exception` attribute.

