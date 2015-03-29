require 'erb'

require 'pathname'
require 'singleton'
class Config
  include Singleton
  def initialize
    @configs = YAML.load_file(Pathname.new './config/lifemessager.yml')
  end

  def [] name
    @configs[name]
  end
end


def upload_file! file_name
  file_name = file_name.gsub /^\//, ''
  upload! StringIO.new(File.read(file_name)), "#{shared_path}/#{file_name}"
end

def template template_name
  config_file = "#{fetch(:templates_path)}/#{template_name}"
  StringIO.new ERB.new(File.read(config_file)).result(binding)
end

def dir_exists? path
  test "[ -d #{path} ]"
end

def file_exists? path
  test "[ -e #{path} ]"
end

def bin_exists? bin
  test "hash #{bin}"
end

def gem_exists? gem
  return false if gem.nil? || gem.empty?
  test :gem, "list | grep '#{gem} '"
end

def gem_install *gems
  result_gems = gems.delete_if { |gem| gem_exists? gem }
  gem_install! *result_gems
end

def gem_install! *gems
  return if gems.empty?
  execute :gem, :install, *gems
end

def cap_configs name
  -> { Config.instance[fetch(:stage).to_s][name] }
end
