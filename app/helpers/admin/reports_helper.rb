module Admin::ReportsHelper
  def event_select_options
    @campaign.events.collect do |e|
      [truncate("#{e['key']}: #{e['State']}, #{e['City'].capitalize} - #{e['Event_Name']}", 40), e['key'].to_i]
    end
  end

  def event_id_to_city
    map = {}
    @campaign.events.each {|e| map[e['key']] = e['City']}
    map 
  end

  def event_id_to_state
    map = {}
    @campaign.events.each {|e| map[e['key']] = e['State']}
    map 
  end

  def event_id_form_column(report, input_name)
    select(:report, :event_id, event_select_options, {:include_blank => true, :selected => report.event_id}, {:name => input_name})
  end

  def mp3_player(report)
    if report.voice_mail
      controller.send(:render_to_string, :partial => "mp3_player", 
          :locals => {:id => report.voice_mail.id, :file => report.voice_mail.public_filename})
    end
  end

  def file_status_column(report)
    report.file_status.humanize if report.file_status
  end
 
  def file_status_form_column(report, input_name)
    select(:report, :file_status, Report::FILE_STATUS.map{|f| [f.humanize, f]}, {:selected => report.file_status}, {:name => input_name})
  end

  def voice_mail_column(report)
    mp3_player(report)
  end

  def voice_mail_form_column(report, input_name)
    mp3_player(report)
  end
  
  def city_form_column(report, input_name)
    text_field(:report, :city) + " Phone city: #{report.phone_city}"
  end

  def country_code_form_column(report, input_name)
    select(:report, :country_code, CountryCodes::countries_for_select('name', 'numeric').sort, {}, {:name => input_name})
  end

  def latitude_form_column(report, input_name)
    report.latitude
  end
  
  def longitude_form_column(report, input_name)
    report.longitude
  end
  
  def created_at_form_column(report, input_name)
    report.created_at.strftime("%m/%d/%Y %I:%M%p")
  end
end
