# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "🌱 Starting seed process..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  ProjectMembership.destroy_all
  Project.destroy_all
  Session.destroy_all
  User.destroy_all
end

# Create 10 users with a shared password for testing
puts "\n👤 Creating 10 users..."
users = 10.times.map do |i|
  user = User.create!(
    name: Faker::Name.name,
    email_address: Faker::Internet.unique.email,
    password: "Password1234*",
    password_confirmation: "Password1234*"
  )
  puts "  ✓ Created user: #{user.name} (#{user.email_address})"
  user
end

# Create 100 projects (10 per user)
puts "\n📁 Creating 100 projects (10 per user)..."
projects = []
users.each_with_index do |user, user_index|
  10.times do |project_index|
    # Generate a description that's at least 50 characters
    description = Faker::Lorem.paragraph(sentence_count: 3, supplemental: true, random_sentences_to_add: 2)

    project = Project.create!(
      name: Faker::App.name,
      description: description,
      project_memberships_attributes: [
        {
          user: user,
          role: ProjectMembership::OWNER,
          status: ProjectMembership::ACTIVE
        }
      ]
    )
    projects << project
    print "." if (user_index * 10 + project_index + 1) % 10 == 0
  end
end
puts "\n  ✓ Created 100 projects"

# Create cross-memberships (each user joins 5-10 random projects from other users)
puts "\n🤝 Creating cross-memberships..."
membership_count = 0

users.each do |user|
  # Get projects this user doesn't own
  available_projects = projects.reject { |p| p.owner == user }

  # Randomly select 5-10 projects to join
  num_to_join = rand(5..10)
  projects_to_join = available_projects.sample(num_to_join)

  projects_to_join.each do |project|
    project.create_membership!(user)
    membership_count += 1
  end

  puts "  ✓ #{user.email_address} joined #{projects_to_join.count} projects"
end

# Summary
puts "\n" + "="*60
puts "✅ Seed completed successfully!"
puts "="*60
puts "📊 Summary:"
puts "  • Users created: #{User.count}"
puts "  • Projects created: #{Project.count}"
puts "  • Total memberships: #{ProjectMembership.count}"
puts "    - Owner memberships: #{ProjectMembership.where(role: ProjectMembership::OWNER).count}"
puts "    - Member memberships: #{ProjectMembership.where(role: ProjectMembership::MEMBER).count}"
puts "\n🔑 All users have password: Password1234*"
puts "="*60
