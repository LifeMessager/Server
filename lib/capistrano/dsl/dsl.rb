require 'erb'

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

def gem_install *gems
  execute :gem, :install, *gems
end

def cap_configs name
  -> { fetch(:configs)[fetch(:stage).to_s][name] }
end
