spec = Gem::Specification.new do |s|
  s.name = 'robustthread'
  s.rubyforge_project = 'robustthread'
  s.version = '0.5'
  s.summary = 'Threads that stay alive'
  s.description = 'Trivial module that allows you to create threads that are not killed if the process exits cleanly'
  s.files = ['lib/robustthread.rb']
  s.require_path = 'lib'
  s.has_rdoc = true
  s.author = 'Jared Kuolt'
  s.email = 'me@superjared.com'
  s.homepage = 'http://github.com/JaredKuolt/robustthread/tree/master'
end
