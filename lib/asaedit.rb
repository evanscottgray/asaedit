require 'cisco'
require 'securerandom'

# Overrides yeah!
# Cisco doesn't properly implement SSH on the ASA platfrom currently. Incredibly this is an issue across all ASA code versions.
module Net
  module SSH
    module Transport
      module PacketStream
        def next_packet(mode=:nonblock)
          case mode
            when :nonblock then
              if available_for_read?
                if fill <= 0
#           raise Net::SSH::Disconnect, "connection closed by remote host"
                end
              end
              poll_next_packet

            when :block then
              loop do
                packet = poll_next_packet
                return packet if packet

                loop do
                  result = Net::SSH::Compat.io_select([self]) or next
                  break if result.first.any?
                end

                if fill <= 0
#           raise Net::SSH::Disconnect, "connection closed by remote host"
                end
              end
            else
              raise ArgumentError, "expected :block or :nonblock, got #{mode.inspect}"
          end
        end
      end
    end
  end
end

def get_users
  asa_user = CONFIG['asa_user']
  asa_ip = CONFIG['asa_ip']
  asa_user_password = CONFIG['asa_user_password']
  asa_prompt = CONFIG['asa_prompt']

  asa = Cisco::Base.new(:host => asa_ip, :user => asa_user, :password => asa_user_password, :transport => :ssh)
  asa.clear_init
  asa.enable(asa_user_password.to_s)
  asa.cmd('terminal pager 0')
  asa.cmd('sh ru | i username')
  output = asa.run
  #output.each do |line|
  #  puts line
  #end
  output
end

def users
  resp = get_users.last.gsub("sh ru | i username\n", '').gsub("\n\r#{asa_prompt}", '').split("\n")
  resp.collect { |x| x.scan(/username .+ password/).first.split(' ')[1] }
end

def is_valid?(username)
  restricted = CONFIG['restricted_users']
  restricted.each do |user|
    if username.to_s == user.to_s
      raise ArgumentError, 'Restricted Username'
      false
    end
  end
  true
end

def make_user(username)
  clean_username = username.match(/[a-z]{1,12}\.[a-z]{1,12}/)
  clean_password = SecureRandom.base64(15)
  if clean_username.nil?
    raise ArgumentError, 'Empty Username'
  else
    if is_valid? username
      asa = Cisco::Base.new(:host => asa_ip, :user => asa_user, :password => asa_user_password, :transport => :ssh)
      asa.clear_init
      asa.enable(asa_user_password.to_s)
      asa.cmd('terminal pager 0')
      asa.cmd('conf t')
      asa.cmd("username #{clean_username} password #{clean_password} privilege 0")
      asa.cmd('end')
      asa.run
    end
  end
  {:username => clean_username.to_s, :password => clean_password}
end
