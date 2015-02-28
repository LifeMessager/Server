set :stage, :production
set :branch, 'master'
set :rails_env, fetch(:stage)

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
#role :app, %w{deploy@example.com}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
server cap_configs('server_name').call, user: fetch(:deploy_user), roles: %w{web app db}, primary: true #, my_property: :my_value

# setup nginx
set :nginx_server_name, cap_configs('server_name') # Default is server's IP address
set :nginx_use_ssl, true
set :nginx_ssl_cert_local_path, Pathname.new('./config/ssl/cert.crt').to_s
set :nginx_ssl_cert_key_local_path, Pathname.new('./config/ssl/private_key.key').to_s

# setup backup
set :backup_database, true
set :backup_access_key_id, cap_configs('backup_access_key_id')
set :backup_secret_access_key, cap_configs('backup_secret_access_key')
set :backup_bucket, cap_configs('backup_bucket')
set :backup_gpg_email, cap_configs('backup_gpg_email')
set :backup_gpg_public_key, cap_configs('backup_gpg_public_key')
set :backup_notify_url, cap_configs('backup_notify_url')
set :backup_notify_params, cap_configs('backup_notify_params')

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options
