module Eventable
  extend ActiveSupport::Concern

  include Giji
  included do
    field :_id, default: ->{ [story_id, turn].join("-") }
    field :turn, type: Integer
    field :name
    field :messages, type: Array

    has_many :potofs,      inverse_of: :event
    belongs_to :story,     inverse_of: :events

    scope :summary, only(:_type, :story_id, :turn, :name).order_by(:turn.asc)
    paginates_per 50
  end
end