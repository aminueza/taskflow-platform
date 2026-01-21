# frozen_string_literal: true

# Seed data for TaskFlow application
# Run with: rails db:seed

puts '🌱 Seeding database...'

# Clear existing data (in reverse order of dependencies)
puts '  Clearing existing data...'
Task.destroy_all
User.destroy_all

# ============================================================================
# USERS
# ============================================================================
puts '  Creating users...'

default_password = 'password123'

users = [
  {
    username: 'alice',
    email: 'alice@example.com',
    password: default_password
  },
  {
    username: 'bob',
    email: 'bob@example.com',
    password: default_password
  },
  {
    username: 'carol',
    email: 'carol@example.com',
    password: default_password
  },
  {
    username: 'david',
    email: 'david@example.com',
    password: default_password
  },
  {
    username: 'eve',
    email: 'eve@example.com',
    password: default_password
  }
].map do |attrs|
  User.create!(attrs)
end

puts "  ✓ Created #{users.count} users"

# ============================================================================
# TASKS
# ============================================================================
puts '  Creating tasks...'

tasks_data = [
  {
    title: 'Deploy Rails app to Azure',
    description: 'Configure Puppet manifests and deploy the Rails application to Azure VMs using the hub-spoke network architecture.',
    status: 'in_progress',
    user: users[0]
  },
  {
    title: 'Fix production database connection timeout',
    description: 'Users are experiencing intermittent database connection errors. Need to investigate and fix the connection pool settings.',
    status: 'pending',
    user: users[1]
  },
  {
    title: 'Security audit for bastion access',
    description: 'Review and document all bastion host access controls, JIT policies, and session recording compliance.',
    status: 'pending',
    user: users[2]
  },
  {
    title: 'Set up Grafana alerting',
    description: 'Configure Prometheus alerting rules and Grafana notification channels for SLO breaches.',
    status: 'in_progress',
    user: users[0]
  },
  {
    title: 'Implement user authentication API',
    description: 'Add JWT-based authentication endpoints for the mobile app team.',
    status: 'completed',
    user: users[1]
  },
  {
    title: 'Write RSpec tests for TasksController',
    description: 'Achieve 90% test coverage for the tasks API endpoints including edge cases.',
    status: 'in_progress',
    user: users[3]
  },
  {
    title: 'Configure Sidekiq for background jobs',
    description: 'Set up Sidekiq queues, retry policies, and dead job handling for email notifications.',
    status: 'completed',
    user: users[2]
  },
  {
    title: 'Document API endpoints with Swagger',
    description: 'Add OpenAPI/Swagger documentation for all REST API endpoints.',
    status: 'pending',
    user: users[4]
  },
  {
    title: 'Refactor user model validations',
    description: 'Clean up validation logic and add custom error messages for better UX.',
    status: 'pending',
    user: users[3]
  },
  {
    title: 'Add dark mode to web UI',
    description: 'Implement dark mode toggle using Tailwind CSS dark variant.',
    status: 'completed',
    user: users[4]
  },
  {
    title: 'Optimize database queries',
    description: 'Review slow queries in PostgreSQL and add appropriate indexes.',
    status: 'pending',
    user: users[1]
  },
  {
    title: 'Update README documentation',
    description: 'Refresh the README with latest setup instructions and architecture diagrams.',
    status: 'completed',
    user: users[0]
  },
  {
    title: 'Research Kubernetes migration',
    description: 'Evaluate moving from VM-based deployment to AKS for better scalability.',
    status: 'pending',
    user: nil
  },
  {
    title: 'Set up load testing with k6',
    description: 'Create k6 scripts for load testing the API under production-like conditions.',
    status: 'pending',
    user: nil
  },
  {
    title: 'Update Puppet modules to latest version',
    description: 'Several Puppet modules have security updates available.',
    status: 'pending',
    user: users[2]
  }
]

tasks = tasks_data.map do |attrs|
  Task.create!(attrs)
end

puts "  ✓ Created #{tasks.count} tasks"

# ============================================================================
# SUMMARY
# ============================================================================
puts ''
puts '✅ Seed complete!'
puts ''
puts '📊 Summary:'
puts "   Users:  #{User.count}"
puts "   Tasks:  #{Task.count}"
puts "     - Pending:     #{Task.where(status: "pending").count}"
puts "     - In Progress: #{Task.where(status: "in_progress").count}"
puts "     - Completed:   #{Task.where(status: "completed").count}"
puts ''
