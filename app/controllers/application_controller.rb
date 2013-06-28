class ApplicationController < ActionController::Base
  helper_method :gon
  helper_method :theme

  protect_from_forgery
  include CurrentAuthenticated

=begin
  case Rails.env
  when 'development'    
    before_filter :debug
    def debug
      current.auth ||= Auth.where(nickname:'7korobi').first
      current_save
    end
  end
=end

  protected
  def theme
    "giji"
  end

  def form obj
    url = [:story].each_with_object controller: obj.class.name.collectionize do |symbol, hash|
      hash[:"#{symbol}_id"] = send(symbol)
    end
    if obj.new_record?
      url.merge action: 'create'
    else
      url.merge action: 'update', id: obj.id
    end
  end
end
