class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # below strategy for setting csrf protection in the cookie.  Does this circumvent the csrf in the first place?  Apparently it's OK
  # anyway, it's taken from an SO answer at http://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected
    def verified_request?
      super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
    end
end
