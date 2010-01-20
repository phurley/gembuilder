#!/usr/bin/env ruby

require "rbconfig"
require "rubygems"
require "tmpdir"
require "find"
require "fileutils"
require "rubygems/installer"

class GemBuilderLib
  VERSION = '1.2.0'
  OBJEXT = ".#{Config::CONFIG["OBJEXT"]}"

  # Helper that will do it all
  def self.[](gem,conservative=false)
    gem_builder = GemBuilderLib.new(gem)
    gem_builder.unpack_gem
    gem_builder.build_extensions
    gem_builder.fix_gemspec(conservative)
    gem_builder.build_gem
    gem_builder.cleanup
  end
  
  def initialize(gem)
    @gem_name = gem
    @installer = Gem::Installer.new(@gem_name)
    @format = Gem::Format.from_file_by_path(@gem_name)
  end

  def tmpdir
    @tmpdir ||= File.join(Dir.tmpdir, "gembuilder")
  end

  def installer
    @installer ||= Gem::Installer.new(@gem_name)
  end
  
  def format
    @format ||= Gem::Format.from_file_by_path(@gem_name)
  end
  
  def spec
    @spec ||= format.spec
  end
  
  def unpack_gem
    FileUtils.rm_r(tmpdir) rescue nil
    FileUtils.mkdir_p(tmpdir) rescue nil
    installer.unpack(tmpdir)
  end

  def build_extensions
    installer.build_extensions(tmpdir, format.spec)
  end

  def platform
    # I used to use this to clean up gem names under
    # darwin, not sure it was a good idea though
    # Config::CONFIG['arch'].sub(/[\.0-9]*$/, '')
    Config::CONFIG['arch']
  end
  
  def fix_gemspec(conservative = false)
    files = []
    Find.find(tmpdir) do |fname|
      next if fname == tmpdir
      next if !conservative && File.extname(fname) == OBJEXT 
      files << fname.sub(Regexp.quote(tmpdir + "/"), '')
    end

    spec.extensions = []
    spec.files += (files - format.spec.files)
    spec.platform = platform
  end
  
  def build_gem
    start_dir = Dir.pwd
    Dir.chdir(tmpdir) do
      gb = Gem::Builder.new(spec)
      gb.build
      FileUtils.mv Dir.glob("*.gem"), start_dir
    end
  end
  
  def cleanup
    FileUtils.rm_rf(tmpdir)
  end

end

