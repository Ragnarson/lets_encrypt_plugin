Rails.application.routes.draw do
  mount LetsEncryptPlugin::Engine => "/lets_encrypt_plugin"
end
