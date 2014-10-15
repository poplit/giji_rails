object @face
attributes :face_id, :sow_auth_ids, :story_ids, :folders, :roles, :wins,  :sow_auth_id, :story_id, :folder, :role, :win, :says

node :story_logs do
  MapReduce::MessageByStory.face_says(@face.face_id)
end

node :say_titles do
  MapReduce::Message::SAYS
end

node :comment_by_phase do
  chr_votes.group_by(&:phase)
end