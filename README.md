# Co-Create

A collaborative project management application built with Ruby on Rails 8, featuring modern frontend tooling and authentication.

## Tech Stack

### Backend
- **Ruby** 3.4.7
- **Rails** 8.1.1
- **Database**: SQLite3
- **Authentication**: BCrypt (secure password hashing)
- **Authorization**: Pundit (role-based access control)
- **Web Server**: Puma
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable

### Frontend
- **JavaScript**: Import maps (ESM)
- **CSS**: Tailwind CSS
- **Framework**: Hotwire (Turbo + Stimulus)
- **Asset Pipeline**: Propshaft

### Testing
- **Framework**: RSpec
- **Factories**: Factory Bot
- **Browser Testing**: Capybara + Selenium WebDriver
- **Test Data**: Faker

### Development Tools
- **Security Auditing**: Brakeman, Bundler Audit
- **Code Quality**: RuboCop (Rails Omakase)
- **Image Processing**: ImageMagick/Vips
- **Deployment**: Kamal (Docker-based deployment)

## Prerequisites

- Ruby 3.4.7
- SQLite3
- Node.js (for asset compilation)
- ImageMagick or libvips (for image processing)

## Installation

### 1. Clone the repository
```bash
git clone <repository-url>
cd co-create
```

### 2. Install dependencies
```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies (if using npm)
npm install
```

### 3. Setup the database
```bash
# Create and migrate the database
bin/rails db:create
bin/rails db:migrate

# (Optional) Seed the database with sample data
bin/rails db:seed
```

### 4. Setup Tailwind CSS
```bash
bin/rails tailwindcss:install
```

## Running the Application

### Development Server
```bash
# Start the Rails server and Tailwind CSS watcher
bin/dev

# Or start services separately:
bin/rails server  # Rails server on http://localhost:3000
bin/rails tailwindcss:watch  # Tailwind CSS watcher
```

The application will be available at `http://localhost:3000`

## Testing

### Run the test suite
```bash
# Run all specs
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
bundle exec rspec --format documentation
```

### Security Audits
```bash
# Check for gem vulnerabilities
bundle exec bundler-audit check --update

# Run static security analysis
bundle exec brakeman
```

### Code Quality
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-correct offenses
bundle exec rubocop -a
```

## Database

The application uses SQLite3 for all environments:
- **Development**: `storage/development.sqlite3`
- **Test**: `storage/test.sqlite3`
- **Production**: Multiple databases (primary, cache, queue, cable)

### Database Commands
```bash
# Reset database
bin/rails db:reset

# Rollback migration
bin/rails db:rollback

# Check migration status
bin/rails db:migrate:status
```

## Key Features

- User authentication with secure password handling
- Project management
- Role-based authorization with Pundit
- Modern, responsive UI with Tailwind CSS
- Real-time updates with Hotwire Turbo
- Image upload and processing
- Background job processing

## Deployment

This application is configured for deployment with Kamal and Docker.

```bash
# Deploy to production
kamal deploy

# Check deployment status
kamal app details
```

See `.kamal/` directory for deployment configuration.

## Project Structure

```
app/
├── controllers/    # Application controllers
├── models/        # ActiveRecord models (User, Project, Session)
├── views/         # View templates
├── policies/      # Pundit authorization policies
└── assets/        # Stylesheets, JavaScript, images

config/            # Application configuration
db/                # Database migrations and schema
spec/              # RSpec tests
public/            # Static files
```

## Development

### Console Access
```bash
bin/rails console
```

### Database Console
```bash
bin/rails dbconsole
```

### Generate New Resources
```bash
# Generate model
bin/rails generate model ModelName

# Generate controller
bin/rails generate controller ControllerName

# Generate migration
bin/rails generate migration MigrationName
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available for use under the specified license terms.
