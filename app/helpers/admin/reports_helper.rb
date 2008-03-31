module Admin::ReportsHelper
  def voice_mail_column(report)
    if report.voice_mail
      controller.send(
        :render_to_string, 
        :partial => "mp3_player", 
        :locals => {:id => report.voice_mail.id, :file => report.voice_mail.public_filename}
      )
    end
  end

  def voice_mail_form_column(report, input_name)
    if report.voice_mail
      controller.send(
        :render_to_string, 
        :partial => "mp3_player", 
        :locals => {:id => report.voice_mail.id, :file => report.voice_mail.public_filename}
      )
    end
  end
  
  def state_form_column(report, input_name)
    state_select(report, input_name)
  end
end