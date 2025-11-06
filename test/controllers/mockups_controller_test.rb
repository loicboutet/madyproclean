require "test_helper"

class MockupsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mockups_index_url
    assert_response :success
  end

  test "should get user_dashboard" do
    get mockups_user_dashboard_url
    assert_response :success
  end

  test "should get user_profile" do
    get mockups_user_profile_url
    assert_response :success
  end

  test "should get user_settings" do
    get mockups_user_settings_url
    assert_response :success
  end

  test "should get admin_dashboard" do
    get mockups_admin_dashboard_url
    assert_response :success
  end

  test "should get admin_users" do
    get mockups_admin_users_url
    assert_response :success
  end

  test "should get admin_analytics" do
    get mockups_admin_analytics_url
    assert_response :success
  end

  test "root should route to mockups index" do
    assert_routing '/', controller: 'mockups', action: 'index'
  end
end