module Admin::ReportsHelper
  def mp3_player(report)
    if report.voice_mail
      controller.send(:render_to_string, :partial => "mp3_player", 
          :locals => {:id => report.voice_mail.id, :file => report.voice_mail.public_filename})
    end
  end

  def file_status_column(report)
    report.file_status.humanize
  end
 
  def file_status_form_column(report, input_name)
    select(:report, :file_status, Report::FILE_STATUS.map{|f| [f.humanize, f]}, {}, {:name => input_name})
  end

  def voice_mail_column(report)
    mp3_player(report)
  end

  def voice_mail_form_column(report, input_name)
    mp3_player(report)
  end
  

  def city_form_column(record, input_name)
    text_field(:record, :city) + " Phone city: #{record.phone_city}"
  end

  def country_code_form_column(record, input_name)
    select(:record, :country_code, CountryCodes::countries_for_select('name', 'numeric').sort, {}, {:name => input_name})
  end

  def created_at_form_column(report, input_name)
    report.created_at.strftime("%m/%d/%Y %I:%M%p")
  end
end
