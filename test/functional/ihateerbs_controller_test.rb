require 'test_helper'

class IhateerbsControllerTest < ActionController::TestCase
  setup do
    @ihateerb = ihateerbs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ihateerbs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ihateerb" do
    assert_difference('Ihateerb.count') do
      post :create, :ihateerb => @ihateerb.attributes
    end

    assert_redirected_to ihateerb_path(assigns(:ihateerb))
  end

  test "should show ihateerb" do
    get :show, :id => @ihateerb.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ihateerb.to_param
    assert_response :success
  end

  test "should update ihateerb" do
    put :update, :id => @ihateerb.to_param, :ihateerb => @ihateerb.attributes
    assert_redirected_to ihateerb_path(assigns(:ihateerb))
  end

  test "should destroy ihateerb" do
    assert_difference('Ihateerb.count', -1) do
      delete :destroy, :id => @ihateerb.to_param
    end

    assert_redirected_to ihateerbs_path
  end
end
