# frozen_string_literal: true

module HealFollowHelper
  def group_follows!(user)
    puts 'Setting group follows'
    @group = find_follow_group!(user, user.heal_group_name)
    @group.each do |target|
      follow!(user.account_id, target.account_id) if user.account_id != target.account_id
    end
  end

  def follow!(uid, tid)
    begin
      Follow.create!(account_id: uid, target_account_id: tid)
    rescue
      puts 'user is already following target'
    end
    begin
      Follow.create!(account_id: tid, target_account_id: uid)
    rescue
      puts 'target is already following user'
    end
  end

  def find_follow_group!(user, group)
    if user.admin
      User.all
    elsif user.moderator && (group.eql? 'Global')
      User.all
    else
      User.where('heal_group_name = ? OR admin = ? OR (moderator = ? AND heal_group_name = ?)', group.nil? ? 'Global' : group, true, true, 'Global')
    end
  end

  def destroy_heal_follows!(user)
    # unfollow all
    Follow.where("account_id = #{user.account_id} OR target_account_id = #{user.account_id}").each(&:destroy)
    # update follows
    group_follows!(user)
  end
end
