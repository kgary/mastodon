# frozen_string_literal: true

class Auth::RegistrationsController < Devise::RegistrationsController
  layout :determine_layout

  before_action :set_invite, only: [:new, :create]
  before_action :check_enabled_registrations, only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :set_sessions, only: [:edit, :update]
  before_action :set_instance_presenter, only: [:new, :create, :update]
  before_action :set_body_classes, only: [:new, :create, :edit, :update]
  before_action :require_not_suspended!, only: [:update]

  after_action :set_group_follows, :group_role!, only: [:create]

  skip_before_action :require_functional!, only: [:edit, :update]

  def new
    super(&:build_invite_request)
  end

  def destroy
    not_found
  end

  protected

  def update_resource(resource, params)
    params[:password] = nil if Devise.pam_authentication && resource.encrypted_password.blank?
    super
  end

  def build_resource(hash = nil)
    super(hash)

    resource.locale             = I18n.locale
    resource.invite_code        = params[:invite_code] if resource.invite_code.blank?
    resource.agreement          = true
    resource.current_sign_in_ip = request.remote_ip

    resource.build_account if resource.account.nil?
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit({ account_attributes: [:username], invite_request_attributes: [:text] }, :email, :password, :password_confirmation, :invite_code)
    end
  end

  def after_sign_up_path_for(_resource)
    auth_setup_path
  end

  def after_sign_in_path_for(_resource)
    set_invite

    if @invite&.autofollow?
      short_account_path(@invite.user.account)
    else
      super
    end
  end

  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  def after_update_path_for(_resource)
    edit_user_registration_path
  end

  def check_enabled_registrations
    redirect_to root_path if single_user_mode? || !allowed_registrations?
  end

  def allowed_registrations?
    Setting.registrations_mode != 'none' || @invite&.valid_for_use?
  end

  def invite_code
    if params[:user]
      params[:user][:invite_code]
    else
      params[:invite_code]
    end
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_body_classes
    @body_classes = %w(edit update).include?(action_name) ? 'admin' : 'lighter'
  end

  def set_invite
    invite = invite_code.present? ? Invite.find_by(code: invite_code) : nil
    @invite = invite&.valid_for_use? ? invite : nil
  end

  def determine_layout
    %w(edit update).include?(action_name) ? 'admin' : 'auth'
  end

  def set_sessions
    @sessions = current_user.session_activations
  end

  def require_not_suspended!
    forbidden if current_account.suspended?
  end

  def set_group_follows
    puts 'Setting group follows'
    begin
      @user = User.find_by(email: params[:user][:email])
      @invite = invite_code.present? ? Invite.find_by(code: invite_code) : nil
      @heal_group_name = nil
      @heal_group_name = @invite.comment unless @invite.nil?
      @user.update(heal_group_name: @heal_group_name.to_s, invite_end: (params[:user][:invite_code].nil? ? 'No link' : params[:user][:invite_code]).to_s)
      @user.update(confirmed_at: DateTime.now)
      pp @user
      @group = User.where('heal_group_name = ?', @heal_group_name.nil? ? 'Global' : @heal_group_name)
      @group.each do |target|
        begin
          if @user.account_id != target.account_id
            Follow.create!(account_id: @user.account_id, target_account_id: target.account_id)
            Follow.create!(account_id: target.account_id, target_account_id: @user.account_id)
          end
        rescue
          puts 'Skipping follow, Account has already been taken'
        end
      end
    rescue
      puts 'Unable to access user - Defaulting to py_script'
      py_script = Rails.root.join('bridgesGroupPop.py')
      res = `python3 #{py_script} '{"username": "#{params[:user][:account_attributes][:username]}", "invite_end": "#{params[:user][:invite_code]}", "auth_token": "#{params[:authenticity_token]}"}'`
    end
  end

  def group_role!
    @invite = invite_code.present? ? Invite.find_by(code: invite_code) : nil
    if @invite.nil? || (@invite.role.eql? 'User')
      return @user = User.find_by(email: params[:user][:email])
    end
    if @invite.role.eql? 'Admin'
      @user.update(admin: true)
      return
    end
    @user.update(moderator: true) if @invite.role.eql? 'Moderator'
  end
end
