module AdminHelper
  def activate_link_to(name, options)
    extra = ( ( @current_controller == options[:controller] ) ?  {:class => 'current'} : {} )
    link_to name, options, extra
  end
end
