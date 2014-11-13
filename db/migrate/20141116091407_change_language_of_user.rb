class ChangeLanguageOfUser < ActiveRecord::Migration
  LANGUAGE_MAP = {
    'zh-Hans' => 'zh-Hans-CN',
    'zh-Hant' => 'zh-Hant-TW',
    'en' => 'en'
  }

  def up
    User.find_each do |user|
      user.language = LANGUAGE_MAP[user.language.to_s]
      user.save
    end
  end

  def down
    User.find_each do |user|
      user.language = LANGUAGE_MAP.key user.language.to_s
      user.save
    end
  end
end
