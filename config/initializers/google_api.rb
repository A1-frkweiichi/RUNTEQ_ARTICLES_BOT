require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

Google::Apis::ClientOptions.default.application_name = 'runtekun-recommends-articles'
Google::Apis::ClientOptions.default.application_version = '1.0.0'
