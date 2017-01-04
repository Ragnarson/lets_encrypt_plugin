LetsEncryptPlugin::Engine.routes.draw do
  get ".well-known/acme-challenge/:token" => "application#show"
end
