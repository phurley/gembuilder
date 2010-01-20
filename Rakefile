# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/gembuilderlib.rb'

Hoe.spec('gembuilder') do
  self.version = GemBuilderLib::VERSION
  self.author = 'Patrick Hurley'
  self.email = 'phurley@gmail.com'

  self.summary = 'Create a binary gem, for the current platform.'
  self.description = "Take a gem file that builds an extension and create a binary gem (useful for production servers without a build chain, Amazon EC2, etc)."
  
  self.url = "http://rubyforge.org/projects/gembuilder/"
end

# vim: syntax=Ruby