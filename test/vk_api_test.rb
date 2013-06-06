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

      it 'should return true if no token for current time' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        VkApi::Session.class_variable_set(:@@counter, {'time' => {"token0" => 3}})
        assert_equal session.request_can_be_executed_now?('time', 'token'), true
      end

      it 'should return true if token for current time is less then 3' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        VkApi::Session.class_variable_set(:@@counter, {'time' => {"token" => 2}})
        assert_equal session.request_can_be_executed_now?('time', 'token'), true
      end

      it 'should return false if token for current time is 3' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        VkApi::Session.class_variable_set(:@@counter, {'time' => {"token" => 3}})
        assert_equal session.request_can_be_executed_now?('time', 'token'), false
      end
    end

    describe 'update_counter' do
      it 'should set current time if counter is empty' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@counter, {})
        session.update_counter(time, 'token')
        assert_equal  VkApi::Session.class_variable_get(:@@counter), { time => { 'token' => 1 } }

        VkApi::Session.class_variable_set(:@@counter, nil)
        session.update_counter(time, 'token')
        assert_equal  VkApi::Session.class_variable_get(:@@counter), { time => { 'token' => 1 } }
      end

      it 'should set current time if counter time is less then current time' do
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@counter, { (time - 1) => {:some => :thing}})
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time, 'token')

        assert_equal  VkApi::Session.class_variable_get(:@@counter), { time => { 'token' => 1 } }
      end

      it 'should set count to 1 if no token in current time' do
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@counter, { time => {'token0' => 1}})
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time, 'token1')

        assert_equal  VkApi::Session.class_variable_get(:@@counter), { time => {'token0'=>1, 'token1'=>1} }
      end

      it 'should set increment count by 1 if token exists' do
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@counter, { time => {'token' => 2}})
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time, 'token')

        assert_equal  VkApi::Session.class_variable_get(:@@counter), { time => {'token' => 3} }
      end
    end
  end
end

