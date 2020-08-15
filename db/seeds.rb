Doorkeeper::Application.create!(name: 'Web', superapp: true, redirect_uri: Doorkeeper.configuration.native_redirect_uri, scopes: 'read write follow push')

domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
account = Account.find_or_initialize_by(id: -99, actor_type: 'Application', locked: true, username: domain)
account.save!

#if Rails.env.development?
global = 'Global'
Admin::Healgroup.where(name: global).first_or_initialize(name: global, start_date: DateTime.now).save!
admin  = Account.where(username: ENV['ADMIN_USERNAME']).first_or_initialize(username: ENV['ADMIN_USERNAME'])
admin.save(validate: false)
User.where(email: ENV['ADMIN_EMAIL']).first_or_initialize(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PASSWORD'], password_confirmation: ENV['ADMIN_PASSWORD'], heal_group_name: global, confirmed_at: Time.now.utc, admin: true, account: admin, agreement: true, approved: true).save!
#end

Setting.create!(var: 'registrations_mode', value: 'none')


