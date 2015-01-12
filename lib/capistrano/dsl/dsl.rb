require 'erb'

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
  system "hash #{bin}"
end

def gem_install *gems
  `gem install #{gems.join ' '}`
end

def cap_configs name
  -> { fetch(:configs)[fetch(:stage).to_s][name] }
end
