class MessagesController < BasePastLogController
  expose(:story_events) do
    if story.old_events.present? 
      story.old_events
    else
      story.events
    end
  end
  expose(:events_summary){ story_events.summary.cache }  
  expose(:events){ story_events.order_by(turn:1).cache }
  expose(:event){ story_events.where(turn: params[:turn]).cache.first }
  expose(:messages){ event.messages.summary.cache }

  respond_to :html, :json

  def index
    base
    gon.events = events_summary.map do |event|
      { turn: event.turn,
        name: event.name,
        link: messages_path(event.story_id, event.turn),
      }
    end
    vil_info event
    gon.event  = event
  end

  def file
    base
    events.each do |event|
      event.name = event.name
      vil_info event
    end
    gon.events = events
    gon.event = {turn:0}

    render :index
  end

  protected
  def vil_info(event)
    msg = Message.new(
      logid:    "vilinfo00000",
    )
    msg["template"] = "sow/village_info"

    event.messages.unshift msg
    event[:has_all_messages] = true
  end

  def base
    story[:link] = message_file_path(story.id)
    gon.folder = story.folder
    gon.story  = story
    gon.potofs = story.potofs.order_by(:pno.asc).cache
  end

  def theme
    case story.folder
    when "PAN"
      "pan"
    else
      "giji"
    end
  end
end
