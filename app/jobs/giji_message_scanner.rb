# -*- coding: utf-8 -*-
=begin
  pretense-32
  crazy-53  SS00092, SA00035, SS00093
  perjury-83 (corrupt _id)
=end

require 'timeout'

class GijiMessageScanner < ActiveJob::Base
  queue_as :giji_vils

  def perform  path, fname, type, folder, vid, turn
    source = SowRecordFile.send(type, path, fname, folder, vid, turn )
    return unless source

    story_id = [folder.downcase, vid].join '-'
    event_id = [folder.downcase, vid, turn].join '-'

    stored_ids = Message.in_event(event_id).pluck("logid")
    chk_doubles = []
    requests = Hash.new

    source.each do |o|
      logid, subid  = case fname
                      when /memo.cgi/
                      ['MM' + o.logid, 'M']
                      when /log.cgi/
                      [o.logid, o.logsubid]
                      end
      if chk_doubles.member? logid
        ErrorJob.perform_now "logid is double. #{logid} add 90000 number.", o  unless  stored_ids.member? logid
        logid = logid[0..1] + (90000 + logid[2..-1].to_i).to_s
      end
      chk_doubles.push logid

      next if stored_ids.member? logid
      stored_ids.push  logid

      mestype = SOW_RECORD[folder][:mestypes][o.mestype.to_i]
      case logid[1]
      when "M"
        logid_map = {"ADMIN" => "a", "MAKER" => "m", "SPSAY" => "P"}
        logid_fix = "#{logid_map[mestype] || mestype[0]}#{logid[1..-1]}"
      else
        logid_fix = logid.dup
      end
      logid_fix[2] = 0 if logid[2] == "9"

      # message embedded in
      message = Message.new.tap do |t|
        t.id = [event_id, logid].join("-")
        t.story_id = story_id
        t.event_id = event_id
        t.logid = logid_fix
        t.sow_auth_id = o.uid
        t.date = o.date
        t.log = o.log
        t.subid = subid
        t.face_id = o.cid
        t.csid = o.csid
        t.style = SOW_RECORD[folder][:monospace][o.monospace.to_i]
        t.mestype = mestype
      end
      fix_dic = {
        'へクター' => 'ヘクター'
      }.each do |src, dst|
        o.chrname.gsub!(src, dst)  if  o.chrname[src]
      end

      case message.mestype
      when 'AIM'
        message.name, message.to = o.chrname.split(' → ')
      else
        message.name = o.chrname
      end

      if message.mestype.blank?
        ErrorJob.perform_now  "mestype: null => BSAY", message.attributes
        message.mestype = "BSAY"
      end
      begin
        timeout(60) { message.with(collection:"msg-#{story_id}").save }
      rescue Moped::Errors::OperationFailure => e
        ErrorJob.perform_now  e.inspect, o, message.attributes
        sleep 10
      end
      key = [{ remote_ip: o.remoteaddr, fowardedfor: o.fowardedfor, user_agent: o.agent },{ sow_auth_id: o.uid }]
      requests[ key ] = true
    end
  end

def save
 case @fname
 when /log.cgi/
   Resque.enqueue(self.class, @path, @fname, :log, @folder, @vid, @turn)
 when /memo.cgi/
   Resque.enqueue(self.class, @path, @fname, :memo, @folder, @vid, @turn)
 else
 end
end
end