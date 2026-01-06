# Test Examples from Co-Create Codebase

This file contains real examples from the Co-Create test suite demonstrating the project's testing conventions.

## Model Test Examples

### Testing Validations

```ruby
describe "validations" do
  describe "when name is nil" do
    let(:tag) { FactoryBot.build(:tag, name: nil) }

    it "is invalid" do
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end
  end

  describe "when name is not unique (case insensitive)" do
    let!(:existing_tag) { FactoryBot.create(:tag, name: "rails") }
    let(:tag) { FactoryBot.build(:tag, name: "Rails") }

    it "is invalid" do
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("has already been taken")
    end
  end

  describe "when name is too short" do
    let(:tag) { FactoryBot.build(:tag, name: "a") }

    it "is invalid" do
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("is too short (minimum is 2 characters)")
    end
  end
end
```

### Testing Instance Methods

```ruby
describe "#collaborator?" do
  let!(:owner) { FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project) }
  let!(:owner_membership) {
    FactoryBot.create(
      :project_membership,
      project: project,
      user: owner,
      status: ProjectMembership::ACTIVE,
      role: ProjectMembership::OWNER
    )
  }

  describe "when the user has not project membership" do
    let!(:user) { FactoryBot.create(:user) }

    it "returns false" do
      expect(project.collaborator?(user)).to be false
    end
  end

  describe "when the user has an active project membership" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:active_membership) {
      FactoryBot.create(
        :project_membership,
        project: project,
        user: user,
        status: ProjectMembership::ACTIVE,
        role: ProjectMembership::MEMBER
      )
    }

    it "returns true" do
      expect(project.collaborator?(user)).to be true
    end
  end
end
```

### Testing Callbacks

```ruby
describe "callbacks" do
  describe "normalize_name" do
    describe "when name has leading and trailing whitespace" do
      let(:tag) { FactoryBot.create(:tag, name: "  rails  ") }

      it "strips whitespace" do
        expect(tag.name).to eq("rails")
      end
    end

    describe "when name has uppercase letters" do
      let(:tag) { FactoryBot.create(:tag, name: "Rails") }

      it "converts to lowercase" do
        expect(tag.name).to eq("rails")
      end
    end

    describe "when name has spaces" do
      let(:tag) { FactoryBot.create(:tag, name: "Ruby on Rails") }

      it "converts spaces to hyphens" do
        expect(tag.name).to eq("ruby-on-rails")
      end
    end
  end
end
```

### Testing Scopes

```ruby
describe "scopes" do
  describe ".popular" do
    let!(:popular_tag) { FactoryBot.create(:tag, name: "rails", projects_count: 10) }
    let!(:unpopular_tag) { FactoryBot.create(:tag, name: "python", projects_count: 1) }
    let!(:medium_tag) { FactoryBot.create(:tag, name: "javascript", projects_count: 5) }

    it "orders tags by projects_count in descending order" do
      expect(Tag.popular).to eq([popular_tag, medium_tag, unpopular_tag])
    end
  end

  describe ".search" do
    let!(:rails_tag) { FactoryBot.create(:tag, name: "rails") }
    let!(:ruby_tag) { FactoryBot.create(:tag, name: "ruby") }
    let!(:javascript_tag) { FactoryBot.create(:tag, name: "javascript") }

    describe "when query matches tag name" do
      it "returns matching tags" do
        results = Tag.search("rail")
        expect(results).to include(rails_tag)
        expect(results).not_to include(ruby_tag)
        expect(results).not_to include(javascript_tag)
      end
    end

    describe "when query is blank" do
      it "returns all tags" do
        expect(Tag.search("").count).to eq(3)
        expect(Tag.search(nil).count).to eq(3)
      end
    end
  end
end
```

### Testing Complex Scopes with Tags

```ruby
describe "scopes" do
  let!(:rails_project) { FactoryBot.create(:project, tag_list: ["rails", "backend"]) }
  let!(:js_project) { FactoryBot.create(:project, tag_list: ["javascript", "frontend"]) }
  let!(:fullstack_project) { FactoryBot.create(:project, tag_list: ["rails", "javascript"]) }

  describe ".with_any_tags" do
    describe "when filtering by a single tag" do
      it "returns projects that have that tag" do
        results = Project.with_any_tags(["rails"])
        expect(results).to include(rails_project, fullstack_project)
        expect(results).not_to include(js_project)
      end
    end

    describe "when filtering by multiple tags (OR logic)" do
      it "returns projects that have any of the specified tags" do
        results = Project.with_any_tags(["rails", "javascript"])
        expect(results).to include(rails_project, js_project, fullstack_project)
      end
    end

    describe "when tags parameter is blank" do
      it "returns all projects" do
        expect(Project.with_any_tags([]).to_a).to match_array(Project.all.to_a)
        expect(Project.with_any_tags(nil).to_a).to match_array(Project.all.to_a)
      end
    end
  end

  describe ".with_all_tags" do
    describe "when filtering by multiple tags (AND logic)" do
      it "returns only projects that have all specified tags" do
        results = Project.with_all_tags(["rails", "javascript"])
        expect(results).to eq([fullstack_project])
      end
    end
  end
end
```

### Testing Custom Setters/Getters

```ruby
describe "#tag_list=" do
  describe "when assigning new tag names" do
    let(:project) { FactoryBot.create(:project, tag_list: ["rails", "saas"]) }

    it "creates new tags and assigns them to the project" do
      expect(project.tags.pluck(:name)).to match_array(["rails", "saas"])
    end
  end

  describe "when tags already exist" do
    let!(:existing_tag) { FactoryBot.create(:tag, name: "rails") }
    let(:project) { FactoryBot.create(:project, tag_list: ["rails", "saas"]) }

    it "reuses existing tags instead of creating duplicates" do
      expect(Tag.where(name: "rails").count).to eq(1)
      expect(project.tags).to include(existing_tag)
    end
  end

  describe "when replacing existing tags" do
    let!(:project) { FactoryBot.create(:project, tag_list: ["rails", "ruby"]) }

    it "replaces old tags with new ones" do
      project.tag_list = ["javascript", "react"]
      project.save!

      expect(project.tags.pluck(:name)).to match_array(["javascript", "react"])
      expect(project.tags.pluck(:name)).not_to include("rails", "ruby")
    end
  end

  describe "when exceeding maximum tag limit" do
    let(:project) { FactoryBot.build(:project, tag_list: (1..11).map { |i| "tag#{i}" }) }

    it "is invalid" do
      expect(project).not_to be_valid
      expect(project.errors[:tag_list]).to include("maximum 10 tags allowed")
    end
  end
end
```

## Request Test Examples

### Testing GET Requests

```ruby
describe "GET /projects" do
  let!(:user) { FactoryBot.create(:user) }
  let!(:owner) { FactoryBot.create(:user) }
  let!(:rails_project) { FactoryBot.create(:project, name: "RailsTestProject", tag_list: ["rails", "backend"]) }
  let!(:python_project) { FactoryBot.create(:project, name: "PythonTestProject", tag_list: ["python", "backend"]) }

  before do
    FactoryBot.create(:project_membership, user: owner, project: rails_project, role: "owner", status: "active")
    FactoryBot.create(:project_membership, user: owner, project: python_project, role: "owner", status: "active")
    sign_in user
  end

  describe "with tag filter" do
    describe "when filtering by a single tag" do
      it "shows only projects with that tag" do
        get projects_home_path(tags: ["rails"])

        expect(response).to have_http_status(:success)
        expect(response.body).to include(rails_project.name)
        expect(response.body).not_to include(python_project.name)
      end
    end
  end

  describe "without tag filter" do
    it "shows all projects" do
      get projects_home_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(rails_project.name)
      expect(response.body).to include(python_project.name)
    end
  end
end
```

### Testing POST Requests

```ruby
describe "POST /users/:user_id/projects" do
  let!(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "when creating a project with tags" do
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

  describe "when creating a project with existing tags" do
    let!(:existing_tag) { FactoryBot.create(:tag, name: "rails") }

    it "reuses existing tags instead of creating duplicates" do
      expect {
        post user_projects_path(user), params: {
          project: {
            name: "Test Project",
            description: "A" * 50,
            tag_names: "rails, saas"
          }
        }
      }.to change { Project.count }.by(1)
       .and change { Tag.count }.by(1) # only creates 'saas'

      project = Project.last
      expect(project.tags).to include(existing_tag)
    end
  end

  describe "when tag_names has irregular formatting" do
    it "handles extra spaces and normalizes tags" do
      post user_projects_path(user), params: {
        project: {
          name: "Test Project",
          description: "A" * 50,
          tag_names: "  Rails , SAAS,   Education  "
        }
      }

      project = Project.last
      expect(project.tags.pluck(:name)).to match_array(["rails", "saas", "education"])
    end
  end
end
```

### Testing PATCH/PUT Requests

```ruby
describe "PATCH /users/:user_id/projects/:id" do
  let!(:user) { FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project, tag_list: ["rails", "backend"]) }
  let!(:owner_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "owner") }

  before { sign_in user }

  describe "when updating project tags" do
    it "replaces old tags with new ones" do
      patch user_project_path(user, project), params: {
        project: {
          tag_names: "javascript, frontend"
        }
      }

      project.reload
      expect(project.tags.pluck(:name)).to match_array(["javascript", "frontend"])
      expect(project.tags.pluck(:name)).not_to include("rails", "backend")
    end
  end

  describe "when removing all tags" do
    it "removes all tags from the project" do
      patch user_project_path(user, project), params: {
        project: {
          tag_names: ""
        }
      }

      project.reload
      expect(project.tags).to be_empty
    end
  end
end
```

### Testing DELETE Requests

```ruby
describe "DELETE /project" do
  let!(:owner) { FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project) }
  let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }

  before { sign_in owner }

  describe "when the user is the owner" do
    it "allows user to destroy" do
      expect { delete user_project_path(owner, project) }.
        to change { Project.count }.by(-1)
    end
  end

  describe "when the user is not the owner" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member") }

    before { sign_in user }

    it "does not allow user to destroy" do
      expect { delete user_project_path(user, project) }.
        not_to change { Project.count }
    end
  end
end
```

### Testing Authorization

```ruby
describe "POST #accept" do
  let!(:owner) { FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project) }
  let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
  let!(:user) { FactoryBot.create(:user) }
  let!(:membership_request) { FactoryBot.create(:project_membership_request, user: user, project: project) }

  describe "when user is not the owner" do
    before { sign_in user }

    it "raises an error" do
      expect { post accept_project_membership_request_path(membership_request) }.
        to raise_error { RestrictedToOwnerError }
    end
  end

  describe "when user is the owner" do
    before { sign_in owner }

    it "does not raise an error" do
      expect { post accept_project_membership_request_path(membership_request) }.
        not_to raise_error { RestrictedToOwnerError }
    end

    it "marks the request as accepted" do
      expect {
        post accept_project_membership_request_path(membership_request)
      }.to change {
        membership_request.reload.status
      }.from("pending").to("accepted")
    end

    it "creates a new project membership" do
      expect { post accept_project_membership_request_path(membership_request) }.
        to change { ProjectMembership.count }.by(1)
      expect(user.project_memberships.count).to eq(1)
    end
  end
end
```

### Testing State-Dependent Behavior

```ruby
describe 'POST #create' do
  let!(:owner) { FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project) }
  let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
  let!(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "when user already has a pending membership request" do
    let!(:membership_request) {
      FactoryBot.create(
        :project_membership_request,
        user: user,
        project: project,
        status: ProjectMembershipRequest::PENDING
      )
    }

    it 'does not create a new project membership request' do
      expect {
        post project_membership_requests_path(project_id: project.id)
      }.not_to change { ProjectMembershipRequest.count }
    end
  end

  describe "when user has a rejected membership request" do
    let!(:membership_request) {
      FactoryBot.create(
        :project_membership_request,
        user: user,
        project: project,
        status: ProjectMembershipRequest::REJECTED
      )
    }

    it 'creates a new pending project membership request' do
      expect {
        post project_membership_requests_path(
          project_id: project.id,
          project_membership_request: { description: "Please let me join" }
        )
      }.to change { ProjectMembershipRequest.count }.by(1)
    end
  end
end
```

## Patterns Summary

### Key Conventions Observed

1. **Always use `FactoryBot.create` or `FactoryBot.build` explicitly** (never just `create` or `build`)
2. **Use `let!` with bang** when you need records to exist before test execution
3. **Nested describe blocks** for organizing tests by context
4. **Descriptive test names** that explain the expected behavior
5. **Test both positive and negative cases** for each feature
6. **Always call `.reload`** when testing state changes on existing records
7. **Use `match_array`** for order-independent array comparisons
8. **Use constants** for status/role values (e.g., `ProjectMembership::ACTIVE`)
9. **Test edge cases** like blank inputs, duplicates, limits
10. **Sign in users** explicitly with `sign_in user` before protected actions
