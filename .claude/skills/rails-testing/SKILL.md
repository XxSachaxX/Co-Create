---
name: rails-testing
description: Write RSpec tests for Co-Create Rails app following project conventions. Use when writing model tests, request tests, or testing features like authentication, authorization, validations, associations, scopes, callbacks, or API endpoints.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Rails Testing Skill for Co-Create

This skill helps write RSpec tests that match the Co-Create project's testing conventions and style.

## Test Structure Conventions

### Model Tests

Use `describe` blocks to group related tests by method or feature:

```ruby
require 'rails_helper'

RSpec.describe ModelName, type: :model do
  describe "#method_name" do
    describe "when specific condition" do
      let!(:resource) { FactoryBot.create(:resource) }

      it "describes expected behavior" do
        expect(resource.method_name).to eq(expected_value)
      end
    end

    describe "when different condition" do
      it "describes different behavior" do
        # test implementation
      end
    end
  end

  describe "associations" do
    let(:model) { FactoryBot.create(:model) }

    it "has many associated_models" do
      expect(model).to respond_to(:associated_models)
    end
  end

  describe "validations" do
    describe "when field is nil" do
      let(:model) { FactoryBot.build(:model, field: nil) }

      it "is invalid" do
        expect(model).not_to be_valid
        expect(model.errors[:field]).to include("can't be blank")
      end
    end
  end

  describe "callbacks" do
    describe "callback_name" do
      describe "when condition applies" do
        let(:model) { FactoryBot.create(:model, field: "Value") }

        it "transforms the data appropriately" do
          expect(model.field).to eq("transformed_value")
        end
      end
    end
  end

  describe "scopes" do
    describe ".scope_name" do
      let!(:matching_record) { FactoryBot.create(:model, status: "active") }
      let!(:non_matching_record) { FactoryBot.create(:model, status: "inactive") }

      it "returns records matching the scope criteria" do
        results = Model.scope_name
        expect(results).to include(matching_record)
        expect(results).not_to include(non_matching_record)
      end
    end
  end
end
```

### Request Tests

Use `describe` blocks for HTTP verbs and paths, test authentication and authorization:

```ruby
require 'rails_helper'

RSpec.describe "ResourceName", type: :request do
  describe "GET /path" do
    let!(:user) { FactoryBot.create(:user) }

    before { sign_in user }

    describe "when condition applies" do
      it "returns successful response" do
        get resource_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Expected Content")
      end
    end
  end

  describe "POST /path" do
    let!(:user) { FactoryBot.create(:user) }

    before { sign_in user }

    describe "when creating valid resource" do
      it "creates the resource" do
        expect {
          post resources_path, params: {
            resource: {
              field: "value"
            }
          }
        }.to change { Resource.count }.by(1)
      end
    end
  end

  describe "DELETE /path/:id" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:resource) { FactoryBot.create(:resource) }

    before { sign_in owner }

    describe "when the user is authorized" do
      it "deletes the resource" do
        expect { delete resource_path(resource) }.
          to change { Resource.count }.by(-1)
      end
    end

    describe "when the user is not authorized" do
      let!(:other_user) { FactoryBot.create(:user) }

      before { sign_in other_user }

      it "does not delete the resource" do
        expect { delete resource_path(resource) }.
          not_to change { Resource.count }
      end
    end
  end
end
```

## FactoryBot Conventions

### Factory Usage

- **Always use `FactoryBot.create`** for records that need persistence
- **Always use `FactoryBot.build`** for records that don't need persistence (e.g., testing validations)
- Use `let!` (with bang) when you need the record to exist before the test runs
- Use `let` (without bang) when lazy evaluation is acceptable

```ruby
# Persisted record needed for associations or database queries
let!(:user) { FactoryBot.create(:user) }

# Build for validation tests (doesn't need to be saved)
let(:invalid_user) { FactoryBot.build(:user, email_address: nil) }

# Lazy evaluation is fine
let(:project) { FactoryBot.create(:project) }
```

### Factory Attributes

Use Faker for dynamic data in factories:

```ruby
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { "password" }
  end

  factory :project do
    name { Faker::Lorem.word }
    description { "A very long description that exceeds the maximum length" }
  end

  factory :tag do
    sequence(:name) { |n| "tag#{n}" }
    projects_count { 0 }
  end
end
```

### Factory Traits

Use traits for variations:

```ruby
factory :project do
  name { Faker::Lorem.word }
  description { "Long description" }

  trait :with_tags do
    transient do
      tag_count { 3 }
    end

    after(:create) do |project, evaluator|
      FactoryBot.create_list(:tag, evaluator.tag_count).each do |tag|
        project.tags << tag
      end
    end
  end
end

# Usage
let(:project_with_tags) { FactoryBot.create(:project, :with_tags) }
let(:project_with_5_tags) { FactoryBot.create(:project, :with_tags, tag_count: 5) }
```

### Overriding Factory Attributes

Pass attributes directly to override defaults:

```ruby
let!(:project) { FactoryBot.create(:project, name: "Specific Name") }
let!(:owner_membership) {
  FactoryBot.create(
    :project_membership,
    user: owner,
    project: project,
    role: "owner",
    status: "active"
  )
}
```

## Authentication Helper

Use `sign_in` helper for request tests (defined in spec/authentication_helper.rb):

```ruby
require 'rails_helper'

RSpec.describe "ResourceName", type: :request do
  let!(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  it "allows authenticated user to access" do
    get resource_path
    expect(response).to have_http_status(:success)
  end
end
```

## Test Naming Conventions

### Describe Blocks

- First level: Feature/method name (`describe "#method_name"` or `describe "GET /path"`)
- Second level: Condition (`describe "when user is authenticated"`)
- Use `describe` for grouping, not `context`

### It Blocks

- Start with a verb describing the behavior
- Be specific about what's being tested
- Avoid "should" in descriptions (implicit in RSpec)

```ruby
# Good
it "returns true if the user has a pending membership request"
it "creates the project and associated tags"
it "handles extra spaces and normalizes tags"

# Avoid
it "should return true"
it "works correctly"
```

## Expectation Patterns

### Testing Changes

```ruby
# Single change
expect { action }.to change { Model.count }.by(1)

# Multiple changes with .and
expect {
  post user_projects_path(user), params: { project: attributes }
}.to change { Project.count }.by(1)
 .and change { Tag.count }.by(2)

# No change
expect { action }.not_to change { Model.count }
```

### Testing Values

```ruby
# Equality
expect(model.field).to eq(expected_value)

# Boolean checks
expect(project.collaborator?(user)).to be true
expect(model).to be_valid
expect(model).not_to be_valid

# Array matching (order independent)
expect(project.tags.pluck(:name)).to match_array(["rails", "saas"])

# Inclusion
expect(results).to include(record)
expect(results).not_to include(other_record)
expect(model.errors[:field]).to include("error message")

# Empty checks
expect(collection).to be_empty

# Response checks
expect(response).to have_http_status(:success)
expect(response.body).to include("Expected Text")
expect(response).to redirect_to(path)
```

### Testing State Changes

```ruby
it "marks the request as accepted" do
  expect {
    post accept_path(request)
  }.to change {
    request.reload.status
  }.from("pending").to("accepted")
end
```

## Project-Specific Patterns

### Testing Associations

```ruby
describe "associations" do
  let(:model) { FactoryBot.create(:model) }

  it "has many associated_models" do
    expect(model).to respond_to(:associated_models)
  end

  it "has many others through join_table" do
    expect(model).to respond_to(:others)
  end
end
```

### Testing Project Membership/Roles

Always create owner membership explicitly:

```ruby
let!(:owner) { FactoryBot.create(:user) }
let!(:project) { FactoryBot.create(:project) }
let!(:owner_membership) {
  FactoryBot.create(
    :project_membership,
    user: owner,
    project: project,
    role: ProjectMembership::OWNER,
    status: ProjectMembership::ACTIVE
  )
}
let!(:member) { FactoryBot.create(:user) }
let!(:member_membership) {
  FactoryBot.create(
    :project_membership,
    user: member,
    project: project,
    role: ProjectMembership::MEMBER,
    status: ProjectMembership::ACTIVE
  )
}
```

### Testing Tag Functionality

```ruby
# Create with tag_list array
let!(:project) { FactoryBot.create(:project, tag_list: ["rails", "saas"]) }

# Create with tag_names string
let!(:project) { FactoryBot.create(:project, tag_names: "rails, saas") }

# Test tag normalization
let(:project) { FactoryBot.create(:project, tag_list: ["Rails", "SAAS"]) }

it "normalizes to lowercase" do
  expect(project.tags.pluck(:name)).to match_array(["rails", "saas"])
end
```

### Testing Scopes with Tags

```ruby
describe ".with_any_tags" do
  let!(:rails_project) { FactoryBot.create(:project, tag_list: ["rails", "backend"]) }
  let!(:js_project) { FactoryBot.create(:project, tag_list: ["javascript", "frontend"]) }

  describe "when filtering by a single tag" do
    it "returns projects that have that tag" do
      results = Project.with_any_tags(["rails"])
      expect(results).to include(rails_project)
      expect(results).not_to include(js_project)
    end
  end
end
```

### Testing Request Params with Tags

```ruby
describe "POST /users/:user_id/projects" do
  let!(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  it "creates the project and associated tags" do
    expect {
      post user_projects_path(user), params: {
        project: {
          name: "Test Project",
          description: "A" * 50,
          tag_names: "rails, saas"
        }
      }
    }.to change { Project.count }.by(1)
     .and change { Tag.count }.by(2)

    project = Project.last
    expect(project.tags.pluck(:name)).to match_array(["rails", "saas"])
  end
end
```

## Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/models/project_spec.rb

# Specific line
bundle exec rspec spec/models/project_spec.rb:10

# By type
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
```

## Test Writing Checklist

When writing tests for a new feature:

1. **Model tests** (if model changes):
   - [ ] Validations
   - [ ] Associations
   - [ ] Callbacks
   - [ ] Scopes
   - [ ] Public methods
   - [ ] Edge cases

2. **Request tests** (for controller actions):
   - [ ] Happy path (authenticated user)
   - [ ] Authorization (different user roles)
   - [ ] Invalid parameters
   - [ ] Edge cases
   - [ ] Response format (status, redirects, content)

3. **General**:
   - [ ] Use appropriate `let` vs `let!`
   - [ ] Test both positive and negative cases
   - [ ] Use descriptive test names
   - [ ] Group related tests with `describe` blocks
   - [ ] Reload records when testing state changes
   - [ ] Clean up test data (handled automatically by transactional fixtures)

## Common Patterns Reference

See [examples.md](examples.md) for comprehensive test examples from the codebase.
