# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Co-Create is a collaborative project management application built with Rails 8, featuring modern frontend tooling with Hotwire (Turbo + Stimulus), Tailwind CSS, and a custom authentication system. The app allows users to create projects, request membership, and collaborate with other users.

## Development Commands

### Starting the Application
```bash
bin/dev                              # Start Rails server + Tailwind CSS watcher (recommended)
bin/rails server                     # Rails server only (port 3000)
bin/rails tailwindcss:watch          # Tailwind CSS watcher only
```

### Testing
```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/models/       # Run model tests
bundle exec rspec spec/requests/     # Run request tests
bundle exec rspec spec/path/to/file_spec.rb  # Run specific test file
bin/rails db:test:prepare test      # Run minitest suite
bin/rails db:test:prepare test:system  # Run system tests
```

### Code Quality & Security
```bash
bundle exec rubocop                  # Run linter
bundle exec rubocop -a               # Auto-correct offenses
bin/brakeman --no-pager             # Security vulnerability scan
bin/bundler-audit                    # Check gem vulnerabilities
bin/importmap audit                  # Check JS dependency vulnerabilities
```

### Database
```bash
bin/rails db:migrate                 # Run pending migrations
bin/rails db:rollback                # Rollback last migration
bin/rails db:reset                   # Drop, create, migrate, and seed
bin/rails db:seed                    # Load seed data
bin/rails console                    # Rails console
bin/rails dbconsole                  # Database console
```

### Asset Management
```bash
bin/rails tailwindcss:build          # Build Tailwind CSS for production
bin/rails assets:precompile          # Precompile all assets
```

### Deployment
```bash
kamal deploy                         # Deploy to production via Docker
kamal app details                    # Check deployment status
```

## Architecture

### Authentication System

Custom session-based authentication (not Devise):
- **Current** (app/models/current.rb): Thread-safe current user/session storage using ActiveSupport::CurrentAttributes
- **Authentication concern** (app/controllers/concerns/authentication.rb): Provides session management methods
  - `authenticated?` - Check if user is signed in
  - `start_new_session_for(user)` - Create new session with signed cookie
  - `terminate_session` - Destroy current session
  - `require_authentication` - Before action to protect routes
  - `allow_unauthenticated_access` - Class method to skip authentication for specific actions
- Sessions stored in database with user_agent and ip_address tracking
- Signed permanent cookies with httponly and same_site: :lax

### Authorization

Pundit policies control access:
- **ProjectPolicy** (app/policies/project_policy.rb): Controls who can view, edit, delete, join/leave projects
- **UserPolicy** (app/policies/user_policy.rb): Controls user-related permissions
- Controllers use `authorize @resource` to enforce policies
- Unauthorized access redirects to root with "Not allowed" alert

### Domain Model

**Core entities:**
- **User**: Has many projects through project_memberships, has many sessions
- **Project**: Belongs to owner (user with OWNER role), has many collaborators through project_memberships
  - `owner` - Returns the project owner
  - `owner?(user)` - Check if user is the owner
  - `collaborator?(user)` - Check if user is a collaborator (not owner)
  - `requested_membership?(user)` - Check if user has pending membership request
  - Minimum description length: 50 characters
- **ProjectMembership**: Join table with role (owner/member) and status (pending/active)
  - Roles: `OWNER`, `MEMBER`
  - Statuses: `PENDING`, `ACTIVE`
- **ProjectMembershipRequest**: Users request to join projects, owners approve/reject
- **Session**: Database-backed sessions with user_agent and ip_address

**Concerns:**
- **Uuidable** (app/models/concerns/uuidable.rb): Automatically generates UUID as primary key on create (used by User, Project, ProjectMembership)

### Routing Structure

Key route patterns in config/routes.rb:
- Root path: `projects#index` (requires authentication)
- Home path `/`: `sessions#new` (login page)
- Nested user resources: Users can create/edit/delete their own projects via `/users/:user_id/projects`
- Project membership flow:
  - POST `/projects/:id/join` - Join public project
  - POST `/projects/:id/leave` - Leave project
  - `/project_membership_requests` - Request to join, owner accepts/rejects

### Frontend Stack

- **Hotwire Turbo**: SPA-like navigation without full page reloads
- **Stimulus**: Lightweight JavaScript controllers (in app/javascript/controllers/)
- **Tailwind CSS**: Utility-first CSS framework (config in config/tailwind.config.js)
- **Import maps**: ESM without bundlers (managed via bin/importmap)
- **Propshaft**: Modern asset pipeline

### Internationalization

All user-facing text is extracted to config/locales/en.yml. Structure follows namespace pattern:
```yaml
en:
  controller_name:
    controller:
      flash_messages: "..."
      errors:
        error_key: "..."
    views:
      action_name:
        label: "..."
```

Access in views: `t('.label')` (uses implicit scope from view path)
Access in controllers: `t('controller_name.controller.flash_message')`

### Database

SQLite3 for all environments:
- Development: storage/development.sqlite3
- Test: storage/test.sqlite3
- Production: Multiple SQLite databases (primary, cache, queue, cable via Solid gems)

Primary keys use UUIDs (via Uuidable concern) instead of auto-incrementing integers.

## Development Practices

### Git Hooks

Lefthook runs RuboCop on staged files before commit (configured in .lefthook.yml). Auto-fixes are staged automatically.

### CI Pipeline

GitHub Actions runs 4 jobs (.github/workflows/ci.yml):
1. **scan_ruby**: Brakeman + Bundler Audit
2. **scan_js**: Importmap audit
3. **lint**: RuboCop
4. **test**: Rails test suite
5. **system-test**: System tests with Capybara

All jobs must pass before merging.

### Testing Framework

Uses RSpec (not default Rails minitest) with FactoryBot and Faker. Test files in spec/ directory mirror app/ structure.

## Rails 8 Features

- **Solid Queue**: Database-backed background jobs (replaces Redis/Sidekiq)
- **Solid Cache**: Database-backed caching
- **Solid Cable**: Database-backed WebSockets
- **Propshaft**: Modern asset pipeline (replaces Sprockets)
- **Modern browsers only**: Enforced via `allow_browser versions: :modern` in ApplicationController
