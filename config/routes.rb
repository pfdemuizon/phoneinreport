ActionController::Routing::Routes.draw do |map|
  # See how all your routes lay out with "rake routes"
  map.root :controller => 'admin', :action => 'login'
  map.connect 'admin/:permalink/reports/:action/:id.:format', :controller => 'admin/reports'
  map.connect 'admin/:permalink/reports/:action.:format', :controller => 'admin/reports'
  map.connect 'admin/:permalink/reports/:action/:id', :controller => 'admin/reports'
=begin
  map.namespace :admin do |admin|
    admin.resources :reports, :collection => {:feed => :get}
  end
=end

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
