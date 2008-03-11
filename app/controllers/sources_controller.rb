require 'uri'

class SourcesController < ApplicationController
  def index
  end

  def create
    # TODO Move URL handling logic into model
    # TODO Add conditionals to check for nil params[:source] hash before trying params[:source][:url]
    url = URI.parse(params[:source][:url])
    url.scheme = 'http' unless ['http','ftp'].include?(url.scheme) or url.scheme.nil?
    params[:source][:url] = url.scheme.nil? ? 'http://'+params[:source][:url].strip : url.to_s
    
    source = Source.new(params[:source])
    events = source.to_events
    for event in events
      next if event.title.blank? && event.description.blank? && event.url.blank?
      event.source = source
      event.save!
      if event.venue && event.venue.source.blank?
        event.venue.source = source
        event.venue.save!
      end
    end
    source.save!

    if events.size == 0
      flash[:failure] = "No items found to import. Please see [URL] for more information on what pages Calagator can read."
    else
      s = "<p>Imported #{events.size} entries:</p><ul>"
      for event in events
        s << "<li>#{help.link_to event.title, event_url(event)}</li>"
      end
      s << "</ul>"
      flash[:success] = s
    end

    redirect_to events_path
  end
end
