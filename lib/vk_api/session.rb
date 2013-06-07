# encoding: utf-8
# VK - это небольшая библиотечка на Ruby, позволяющая прозрачно обращаться к API ВКонтакте
# из Ruby.
#
# Author:: Nikolay Karev
# Copyright:: Copyright (c) 2011- Nikolay Karev
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)
#
# Библиотека VkApi имеет один класс - +::VK:Session+. После создания экземпляра сессии
# вы можете вызывать методы ВКонтакте как будто это методы сессии, например:
#   session = ::VkApi::Session.new app_id, api_secret
#   session.friends.get :uid => 12
# Такой вызов вернёт вам массив хэшей в виде:
#   # => [{'uid' => '123'}, {:uid => '321'}]

require 'net/http'
require 'uri'
require 'digest/md5'
require 'json'
require 'active_support/inflector'

module VkApi
  # Единственный класс библиотеки, работает как "соединение" с сервером ВКонтакте.
  # Постоянное соединение с сервером не устанавливается, поэтому необходимости в явном
  # отключении от сервера нет.
  # Экземпляр +Session+ может обрабатывать все методы, поддерживаемые API ВКонтакте
  # путём делегирования запросов.


  class Session
    REQUESTS_PER_SECOND = 3
    VK_API_URL = 'https://api.vk.com'
    VK_OBJECTS = %w(users friends photos wall audio video places secure language notes pages offers
      questions messages newsfeed status polls subscriptions likes)
    attr_accessor :app_id, :api_secret

    @@counter = {}
    # Counter schema: {"token1" => [time11, time12, time13], 'token2' => [time21, tome22, time23], ...}
    # "time" stores in Unix time
    # "token" comes from request
    # count is a number of requests in this second

    # Конструктор. Получает следующие аргументы:
    # * app_id: ID приложения ВКонтакте.
    # * api_secret: Ключ приложения со страницы настроек
    def initialize app_id, api_secret, method_prefix = nil
      @app_id, @api_secret, @prefix = app_id, api_secret, method_prefix
    end


    # Выполняет вызов API ВКонтакте
    # * method: Имя метода ВКонтакте, например friends.get
    # * params: Хэш с именованными аргументами метода ВКонтакте
    # Возвращаемое значение: хэш с результатами вызова.
    # Генерируемые исключения: +ServerError+ если сервер ВКонтакте вернул ошибку.
    def call(method, params = {})
      method = method.to_s.camelize(:lower)
      method = @prefix ? "#{@prefix}.#{method}" : method
      params[:method] = method
      params[:api_id] = app_id
      params[:format] = 'json'
      params[:sig] = sig(params.tap do |s|
        # stringify keys
        s.keys.each {|k| s[k.to_s] = s.delete k  }
      end)

      # http://vk.com/developers.php?oid=-1&p=%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2_%D0%BA_API
      # now VK requires the following url: https://api.vk.com/method/METHOD_NAME
      path = VK_API_URL + "/method/#{method.gsub('.', '')}"
      uri = URI.parse(path)

      # build Post request to VK (using https)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @request = Net::HTTP::Post.new(uri.request_uri)
      @request.set_form_data(params)
      response = execute_request(Time.now.to_i)

      raise ServerError.new self, method, params, response['error'] if response['error']
      response['response']
    end

    def execute_request(time, token)
      @@counter = {} unless @@counter[time]
      if request_can_be_executed_now?(time, token)
        update_counter(time, token)
        JSON.parse(@http.request(@request).body)
      else
        sleep(1)
        update_counter(time + 1, token)
        JSON.parse(@http.request(@request).body)
      end
    end

    def request_can_be_executed_now?(time, token)
      !@@counter[token] || # no requests for this token
      !@@counter[token].first || # times array is empty
      time - @@counter[token].first > 1 || # third request executed more than a second ago
      @@counter[token].length < REQUESTS_PER_SECOND # three requests.per second rule
    end

    def update_counter(time, token)
      if @@counter.nil? || @@counter.empty?
        @@counter = { token => [time] }
      else
        if @@counter[token].nil?
          @@counter[token] = [time]
        else
          if @@counter[token].length < REQUESTS_PER_SECOND
            @@counter[token] << time
          else
            @@counter[token] << time
            @@counter[token] = @@counter[token].drop(1)
          end
        end
      end
    end

    # Генерирует подпись запроса
    # * params: параметры запроса
    def sig(params)
      Digest::MD5::hexdigest(
      params.keys.sort.map{|key| "#{key}=#{params[key]}"}.join +
      api_secret)
    end

    # Генерирует методы, необходимые для делегирования методов ВКонтакте, так friends,
    # images
    def self.add_method method
      ::VkApi::Session.class_eval do
        define_method method do
          if (! var = instance_variable_get("@#{method}"))
            instance_variable_set("@#{method}", var = ::VkApi::Session.new(app_id, api_secret, method))
          end
          var
        end
      end
    end

    for method in VK_OBJECTS
      add_method method
    end

    # Перехват неизвестных методов для делегирования серверу ВКонтакте
    def method_missing(name, *args)
      call name, *args
    end

  end

  # Базовый класс ошибок
  class Error < ::StandardError; end

  # Ошибка на серверной стороне
  class ServerError < Error
    attr_accessor :session, :method, :params, :error
    def initialize(session, method, params, error)
      super "Server side error calling VK method: #{error}"
      @session, @method, @params, @error = session, method, params, error
    end
  end

end
