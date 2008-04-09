class Site < ActiveRecord::Base
  has_many :campaigns do
    def current
      proxy_target.detect {|c| c.current?}
    end
  end

  cattr_accessor :current
  validates_presence_of :host
end
