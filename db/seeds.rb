require "active_record/fixtures"

#if Rails.env.development?
#
#  puts "loading fixtures"
#  order_to_load_fixtures = %w[people users tombstones assistants conversations runs messages steps]
#
#  ActiveRecord::Base.transaction do
#    ActiveRecord::Base.connection.disable_referential_integrity do
#      ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('test', 'fixtures'), order_to_load_fixtures)
#    end
#  end
#end
user = User.new
user.first_name = "Daniel"
user.last_name = "Burns"
user.password = "password"
user.preferences["dark_mode"] = "dark"
user.save!


person = Person.new
person.email = "daniel@boulderseomarketing.com"
person.personable_id = user.id
person.personable_type = "User"
person.save!

user.person = person
user.save!

puts user.first_name.to_s+" Created"
