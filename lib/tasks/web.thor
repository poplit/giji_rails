# -*- coding: utf-8 -*-

class Web < Thor
  desc "deploy", "web-deploy shell create"
  def deploy
  end

  desc "home",   "ssh method create as Home"
  def home
    each_servers{|no| "192.168.0.#{no}"}
    open("/etc/hosts", "w:utf-8") do |f|
      f.puts HOST
      f.puts HOST_HOME
    end
  end

  desc "utage",  "ssh method create as Other domain"
  def utage
    each_servers{|no| "utage.family.jp"}
    open("/etc/hosts", "w:utf-8") do |f|
      f.puts HOST
      f.puts HOST_WEB
    end
  end

  HOST = <<'_HOSTS_'
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1 localhost
255.255.255.255 broadcasthost
::1             localhost
fe80::1%lo0 localhost

113.151.60.93  mongo.family.jp
_HOSTS_

  HOST_HOME = <<'_HOSTS_'
183.181.24.203  giji.sytes.net
192.168.0.101     tv.family.jp
192.168.0.100   7korobi.ddo.jp
192.168.0.249  mongo.family.jp
192.168.0.100  utage.family.jp
_HOSTS_

  HOST_WEB = <<'_HOSTS_'
183.181.24.203  giji.sytes.net
_HOSTS_


  SSH = <<'_SHELL_'
echo "= #{no}:$* "
ssh -p #{no}0 7korobi@#{server} $*
_SHELL_

  PUSH = <<'_SHELL_'
echo "no: #{no}  to: $1  option: $2 $3 $4 $5"
TO=$1

rsync -e "ssh -p #{no}0" -r ${TO}/ 7korobi@#{server}:${TO}/ --exclude='*.svn-base' --exclude='*.svn' --exclude='*.bak'  $2 $3 $4 $5
_SHELL_

  PULL = <<'_SHELL_'
echo "no: #{no}  to: $1  option: $2 $3 $4 $5"
TO=$1

rsync -e "ssh -p #{no}0" -r 7korobi@#{server}:${TO}/ ${TO}/ --exclude='*.svn-base' --exclude='*.svn' --exclude='*.bak'  $2 $3 $4 $5
_SHELL_

  def each_servers
    [240,245,249,250,254].each do |no|
      [["/utage/ssh-#{no}" ,SSH ],
       ["/utage/web-push-#{no}",PUSH],
       ["/utage/web-pull-#{no}",PULL],
      ].each do |fname, shell|
        `mkdir -p /utage/#{no}`
        open(fname,"w") do |f|
          server = yield(no)
          f.puts eval(%Q[%Q|#{shell}|])
        end
        `chmod 755 #{fname}`
      end
    end
  end
end
