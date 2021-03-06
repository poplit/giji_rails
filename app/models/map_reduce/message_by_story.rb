
class MapReduce::MessageByStory
  include Giji

  field :value, type: Hash
  %w[SS VS TS GS].each do |key|
    field :"value.#{key}.face_id", as: :"#{key}_faces", type: Hash
    field :"value.#{key}.sow_auth_id", as: :"#{key}_sow_auth_ids", type: Hash
  end

  def self.frontier_story
    done = MapReduce::MessageByStory.pluck("id")
    SowVillage.not.in(id: done).where(is_finish: true)
  end

  def self.frontier_story_ids
    frontier_story.pluck("id")
  end

  def self.counter(talk, logs, field)
    key = talk[field]
    base = logs[field] ||= {}
    res = base[key] ||= {
      date: {
        min: talk.date,
        max: talk.date,
      },
      max:   0,
      all:   0,
      count: 0,
    }
    res[:date][:min] = talk.date if res[:date][:min] > talk.date
    res[:date][:max] = talk.date if res[:date][:max] < talk.date
    res[:count] += 1

    size = talk.log.to_s.size
    res[:max] = size if res[:max] < size
    res[:all] += size
  end

  def self.generate(target = frontier_story_ids)
    bad_requests = target.to_a & SowVillage.empty_ids
    return if bad_requests.present?

    deny_sow_auth_ids = %w[master admin a1 a2 a3 a4 a5 a6 a7 a8 a9]
    self.in(story_id: target).delete

    target.each do |story_id|
      o = self.new(value: {})
      o.id = story_id

      Message.in_story(story_id).each do |talk|
        next if deny_sow_auth_ids.member? talk.sow_auth_id
        logid_head = talk.logid[0..1]
        logs = o.value[logid_head] ||= {}
        counter(talk, logs, :all)
        counter(talk, logs, :face_id)
        counter(talk, logs, :sow_auth_id)
      end
      o.save
    end
  end
end