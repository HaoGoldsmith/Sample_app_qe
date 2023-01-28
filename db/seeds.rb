# Create a main sample user.
User.create!(name: "Example User",
             email: "example@railstutorial.org",
             password:
               "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)
# Generate a bunch of additional users.
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
               email: email,
               password:
                 password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

# Generate microposts for a subset of users.
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end


# Create a main sample user.
User.create!(name: "Hao",
             email: "saya0304@mail.ru",
             password:
               "qwerty1234",
             password_confirmation: "qwerty1234",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)
# Generate microposts for a 101 user?.
user = User.find(101)
40.times do
  content = Faker::Lorem.sentence(word_count: 5)
  user.microposts.create!(content: content)

  # Create following relationships.
  users = User.all
  user = users.find(101)
  following = users[2..50]
  followers = users[3..40]
  following.each { |followed| user.follow(followed) }
  followers.each { |follower| follower.follow(user) }
  end

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

AdminUser.create!(email: 'saya0304@mail.ru', password: 'qwerty1234', password_confirmation: 'qwerty1234') if Rails.env.development?



