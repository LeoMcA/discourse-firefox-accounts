# name: firefox-accounts
# about: Discourse plugin which adds Firefox Accounts authentication
# version: 0.0.1
# authors: Leo McArdle

require 'auth/oauth2_authenticator'
require 'omniauth-oauth2'

class FirefoxAuthenticator < ::Auth::OAuth2Authenticator
  def register_middleware(omniauth)
    omniauth.provider :firefox,
      SiteSetting.firefox_accounts_client_id,
      SiteSetting.firefox_accounts_client_secret
  end
end

after_initialize do
  class ::OmniAuth::Strategies::Firefox
    option :name, 'firefox'

    option :client_options, {
      :site => SiteSetting.firefox_accounts_oauth_server,
      :authorize_url => '/v1/authorization',
      :token_url => '/v1/token'
    }

    option :authorize_params, {
      :scope => 'profile'
    }

    uid { raw_info['uid'].to_s }

    info do
      {
        :email => raw_info['email'],
        :name => raw_info['displayName']
      }
    end

    extra do
      {
        :raw_info => raw_info
      }
    end

    def raw_info
      @raw_info ||= access_token.get("#{SiteSetting.firefox_accounts_profile_server}/v1/profile").parsed
    end
  end
end

class OmniAuth::Strategies::Firefox < OmniAuth::Strategies::OAuth2
end

auth_provider :title => 'with Firefox',
  :message => 'Authentication with Firefox (make sure pop up blockers are not enabled)',
  :frame_width => 390,
  :frame_height => 550,
  :authenticator => FirefoxAuthenticator.new('firefox', trusted: true)

register_css <<CSS

.btn-social.firefox {
  background: #E66000;
}

.btn-social.firefox:before {
  content: "\\f269";
}

CSS
