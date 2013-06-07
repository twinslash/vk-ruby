require 'net/http'
require_relative 'test_helper'
require_relative '../lib/vk_api.rb'
require_relative '../lib/vk_api/session.rb'

describe VkApi do
  describe VkApi::Session do

    it 'should be initialized with app_id, api_secret, prefix' do
      session = VkApi::Session.new "app_id", "api_secret", "prefix"
      assert_equal session.instance_variable_get(:@app_id), 'app_id'
      assert_equal session.instance_variable_get(:@api_secret), 'api_secret'
      assert_equal session.instance_variable_get(:@prefix), 'prefix'
    end

    describe '@@counter' do
      it "should exist" do
        assert_equal VkApi::Session.class_variables.include?(:@@counter), true
      end

      it 'should be empty after start' do
        assert_equal VkApi::Session.class_variable_get(:@@counter), {}
      end
    end


    describe 'request_can_be_executed_now?' do
      it 'should return true if counter is empty' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        VkApi::Session.class_variable_set(:@@counter, {})
        assert_equal session.request_can_be_executed_now?('time', 'token'), true
      end

      it 'should return true if no requests for current second' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        VkApi::Session.class_variable_set(:@@counter, {'token' => [Time.now.to_f - 2]})
        assert_equal session.request_can_be_executed_now?('time', Time.now.to_f), true
      end

      it 'should return true if less than 3 requests for current second executed' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        time = Time.now.to_f
        VkApi::Session.class_variable_set(:@@counter, {'token' => [time, time]})
        assert_equal session.request_can_be_executed_now?(time, 'token'), true
      end

      it 'should return false if 3 requests for current second executed' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        time = Time.now.to_f
        VkApi::Session.class_variable_set(:@@counter,
                                          {'token' => [time, time, time] })
        assert_equal session.request_can_be_executed_now?(time, 'token'), false
      end
    end

    describe 'update_counter' do
      it 'should set current time if counter is empty' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        time = Time.now.to_f
        VkApi::Session.class_variable_set(:@@counter, {})
        session.update_counter(time, 'token')
        assert_equal  VkApi::Session.class_variable_get(:@@counter), { 'token' => [time] }

        VkApi::Session.class_variable_set(:@@counter, nil)
        session.update_counter(time, 'token')
        assert_equal  VkApi::Session.class_variable_get(:@@counter), { 'token' =>[time] }
      end

      it 'should set first time to token if no token in current time' do
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@counter, { 'token0' => [time]})
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time, 'token1')

        assert_equal  VkApi::Session.class_variable_get(:@@counter), { 'token0' => [time], 'token1' => [time] }
      end

      it 'should add time to token if token exists' do
        time = Time.now.to_f
        VkApi::Session.class_variable_set(:@@counter, { 'token' => [time - 1, time]})
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time, 'token')

        assert_equal  VkApi::Session.class_variable_get(:@@counter), { 'token' => [time - 1, time, time] }
      end
    end
  end
end

