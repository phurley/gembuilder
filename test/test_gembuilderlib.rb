#
# Calling all interested testers -- how could I write better tests for this
# type of code? let me know at phurley@gmail.com -- Thanks!!!
# 
# Could put all the tests in one methods and test them inline? 
# this is an optimization, so I am holding off, the test time 
# is not too bad now that I use a simple project.
# 
# Add tests for complex gems (with multiple extensions)
# 
# Should probably verify that the gem is installable 
# as well, but I am not sure how far to go down that
# road (probably all the way, but it seems so cludgy 
# already)
# 
# And thanks to zenspider for ZenTest -- great stuff
# 
require "test/unit"
require "gembuilderlib"

class TestGembuilder < Test::Unit::TestCase
  GEMNAME = 'helloc-1.0.0.gem'
  
  def setup
    # find our test gem file.
    # Note the nasty reliance on an external file
    # and our eventual use of your file system 
    # slowing the tests
    #
    Dir.chdir "test" rescue nil 
    @gb = GemBuilderLib.new(GEMNAME)
  end
  
  def teardown
    # how craptacular is this -- I am using the thing I am 
    # testing to cleanup -- somebody save me from my own
    # insanity
    @gb.cleanup
    File.rm('helloc-1.0.0-*.gem') rescue nil
  end

  def assert_file_exists(fname, msg = "The file #{fname} should exist and does not.")
    assert(File.exists?(fname), msg)
  end
  
  def assert_file_exists_in_gem(fname, msg = "The file #{fname} should exist and does not.")
    assert_file_exists(File.join(@gb.tmpdir, fname), msg)
  end
  
  def assert_files_exist_in_gem(files)
    files.each { |file| assert_file_exists_in_gem(file) }
  end

  def test_class_doit_all_method
    GemBuilderLib[GEMNAME]
    
    assert_file_exists("helloc-1.0.0-#{Config::CONFIG['arch']}.gem")   
    # not sure how to verify that the temp directory is properly cleaned up
    # without adding some odd support for returning the temp directory name
    # that should already be deleted at this point 
  end
  
  def test_tmpdir_does_not_exist
    assert(!File.exists?(@gb.tmpdir), "Not generating a good temp directory")
  end
  
  def test_we_can_unpack_the_gem
    @gb.unpack_gem
    assert(File.exists?(@gb.tmpdir), "Failure message.")

    assert_files_exist_in_gem ["History.txt", "Manifest.txt", "README.txt", 
      "Rakefile", "ext/helloc/extconf.rb", "ext/helloc/helloc.c"]
  end
  
  def test_we_can_build_the_extensions
    @gb.unpack_gem
    @gb.build_extensions
    assert_files_exist_in_gem [
      "ext/helloc/helloc.#{Config::CONFIG['OBJEXT']}",
      "lib/helloc.#{Config::CONFIG['DLEXT']}"
    ]
  end

  def test_gemspec_changes
    @gb.unpack_gem
    @gb.build_extensions
    @gb.fix_gemspec
    
    assert(@gb.spec.files.include?("lib/helloc.#{Config::CONFIG['DLEXT']}"), "Shared library not found in gemspec")
    assert(!@gb.spec.files.include?("ext/helloc/helloc.#{Config::CONFIG['OBJEXT']}"), "Intermediate file found in gemspec")
  end
  
  def test_build_gem
    @gb.unpack_gem
    @gb.build_extensions
    @gb.fix_gemspec
    @gb.build_gem
    
    # talk about self referential -- but how else to I make the
    # tests work on different platforms?
    assert_file_exists("helloc-1.0.0-#{Config::CONFIG['arch']}.gem")
  end
      
  def test_cleanup
    @gb.unpack_gem
    @gb.build_extensions
    @gb.cleanup
    assert(!File.exists?(@gb.tmpdir))
  end
  
end