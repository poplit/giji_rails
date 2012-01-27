# -*- coding: utf-8 -*-

class Web < Thor
  desc "deploy", "web-deploy shell create"
  def deploy
  end

  desc "home",   "web-ssh method create as Home"
  def home
    each_servers{|no| "192.168.0.#{no}"}
  end

  desc "utage",  "web-ssh method create as Other domain"
  def utage
    each_servers{|no| "utage.sytes.net"}
  end



  SSH = <<'_SHELL_'
echo "no: #{no}  cmd: $* "
ssh -p #{no}0 7korobi@#{server} $*
_SHELL_

  PUSH = <<'_SHELL_'
echo "no: #{no}  to: $1  option: $2"
TO=$1
OPTION=$2

rsync -e "ssh -p #{no}0" -r ${TO}/ 7korobi@#{server}:${TO}/ --exclude='*.svn-base' --exclude='*.svn' --exclude='*.bak' --stats  $OPTION
_SHELL_

  def each_servers
    [250,251,254].each do |no|
      [["/utage/web-ssh-#{no}" ,SSH ],
       ["/utage/web-push-#{no}",PUSH]
      ].each do |fname, shell|
        open(fname,"w") do |f|
          server = yield(no)
          f.puts eval(%Q[%Q|#{shell}|])
        end
      end
    end
  end
end