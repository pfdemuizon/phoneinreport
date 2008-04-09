module Admin::ReportsHelper

  def mp3_player(report)
    if report.voice_mail
      controller.send(:render_to_string, :partial => "mp3_player", 
          :locals => {:id => report.voice_mail.id, 
          :file => report.voice_mail.public_filename})
    end
  end

  def voice_mail_column(report)
    mp3_player(report)
  end

  def voice_mail_form_column(report, input_name)
    mp3_player(report)
  end
  
  def state_form_column(report, state)
    select(report, state, StateSelect.state_options_for_select, {:include_blank => true})
  end

  def created_at_form_column(report, input_name)
    report.created_at.strftime("%m/%d/%Y %I:%M%p")
  end
end
