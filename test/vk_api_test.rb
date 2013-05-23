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

    describe '@@requests_count' do
      it "should exist" do
        assert_equal VkApi::Session.class_variables.include?(:@@requests_count), true
      end

      it 'should not be empty after start' do
        assert_equal VkApi::Session.class_variable_get(:@@requests_count).to_a.length, 1
      end
    end


    describe 'request_can_be_executed_now?' do
      it 'should return true if counter for current time is less then maximum' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@requests_count, {time => 4 })
        assert_equal session.request_can_be_executed_now?(time), true
      end

      it 'should return false if counter for current time is maximum' do
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@requests_count, {time => 5})
        assert_equal session.request_can_be_executed_now?(time), false
      end
    end

    describe 'update_counter' do

      it 'should set current time if counter time is less then current time' do
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@requests_count, { (time - 1) => 4 })
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time)

        assert_equal  VkApi::Session.class_variable_get(:@@requests_count), { time => 0 }
      end

      it 'should increment count by 1' do
        time = Time.now.to_i
        VkApi::Session.class_variable_set(:@@requests_count, { time => 2})
        session = VkApi::Session.new "app_id", "api_secret", "prefix"
        session.update_counter(time)

        assert_equal  VkApi::Session.class_variable_get(:@@requests_count), { time => 3 }
      end
    end
  end
end

