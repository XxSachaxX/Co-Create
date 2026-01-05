require 'rails_helper'

RSpec.describe "Projects", type: :request do
  describe "POST /leave" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member") }
    before { sign_in user }

    it "allows user to leave" do
      expect { post leave_project_path(project) }.
        to change { ProjectMembership.count }.by(-1)
      expect(response).to redirect_to(project_path(project))
    end
  end

  describe "DELETE /project" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }

    before { sign_in owner }

    describe "when the user is the owner" do
      it "does not allow user to destroy" do
        expect { delete user_project_path(owner, project) }.
          to change { Project.count }.by(-1)
      end
    end

    describe "when the user is not the owner" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:user_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member") }

      before { sign_in user }

      it "allows user to destroy" do
        expect { delete user_project_path(user, project) }.
          not_to change { Project.count }
      end
    end
  end

  describe "GET /projects" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:owner) { FactoryBot.create(:user) }
    let!(:rails_project) { FactoryBot.create(:project, name: "RailsTestProject", tag_list: [ "rails", "backend" ]) }
    let!(:python_project) { FactoryBot.create(:project, name: "PythonTestProject", tag_list: [ "python", "backend" ]) }
    let!(:fullstack_project) { FactoryBot.create(:project, name: "FullstackTestProject", tag_list: [ "rails", "python", "frontend" ]) }
    let!(:untagged_project) { FactoryBot.create(:project, name: "UntaggedTestProject") }

    before do
      FactoryBot.create(:project_membership, user: owner, project: rails_project, role: "owner", status: "active")
      FactoryBot.create(:project_membership, user: owner, project: python_project, role: "owner", status: "active")
      FactoryBot.create(:project_membership, user: owner, project: fullstack_project, role: "owner", status: "active")
      FactoryBot.create(:project_membership, user: owner, project: untagged_project, role: "owner", status: "active")
      sign_in user
    end

    describe "with tag filter" do
      describe "when filtering by a single tag" do
        it "shows only projects with that tag" do
          get projects_home_path(tags: [ "rails" ])

          expect(response).to have_http_status(:success)
          expect(response.body).to include(rails_project.name)
          expect(response.body).to include(fullstack_project.name)
          expect(response.body).not_to include(python_project.name)
          expect(response.body).not_to include(untagged_project.name)
        end
      end

      describe "when filtering by multiple tags" do
        it "shows projects with any of the tags (OR logic)" do
          get projects_home_path(tags: [ "rails", "python" ])

          expect(response).to have_http_status(:success)
          expect(response.body).to include(rails_project.name)
          expect(response.body).to include(python_project.name)
          expect(response.body).to include(fullstack_project.name)
          expect(response.body).not_to include(untagged_project.name)
        end
      end

      describe "when filtering by tag with no matches" do
        it "shows no projects" do
          get projects_home_path(tags: [ "nonexistent" ])

          expect(response).to have_http_status(:success)
          expect(response.body).not_to include(rails_project.name)
          expect(response.body).not_to include(python_project.name)
          expect(response.body).not_to include(fullstack_project.name)
          expect(response.body).not_to include(untagged_project.name)
        end
      end
    end

    describe "without tag filter" do
      it "shows all projects" do
        get projects_home_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(rails_project.name)
        expect(response.body).to include(python_project.name)
        expect(response.body).to include(fullstack_project.name)
        expect(response.body).to include(untagged_project.name)
      end
    end
  end

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
        expect(project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
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

    describe "when creating a project without tags" do
      it "creates the project successfully" do
        initial_tag_count = Tag.count

        expect {
          post user_projects_path(user), params: {
            project: {
              name: "Test Project",
              description: "A" * 50
            }
          }
        }.to change { Project.count }.by(1)

        expect(Tag.count).to eq(initial_tag_count)

        project = Project.last
        expect(project.tags).to be_empty
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
        expect(project.tags.pluck(:name)).to match_array([ "rails", "saas", "education" ])
      end
    end
  end

  describe "PATCH /users/:user_id/projects/:id" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, tag_list: [ "rails", "backend" ]) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "owner") }

    before do
      sign_in user
    end

    describe "when updating project tags" do
      it "replaces old tags with new ones" do
        patch user_project_path(user, project), params: {
          project: {
            tag_names: "javascript, frontend"
          }
        }

        project.reload
        expect(project.tags.pluck(:name)).to match_array([ "javascript", "frontend" ])
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

    describe "when adding tags to untagged project" do
      let!(:untagged_project) { FactoryBot.create(:project) }
      let!(:owner_membership2) { FactoryBot.create(:project_membership, user: user, project: untagged_project, role: "owner") }

      it "adds the tags successfully" do
        patch user_project_path(user, untagged_project), params: {
          project: {
            tag_names: "rails, saas"
          }
        }

        untagged_project.reload
        expect(untagged_project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
      end
    end
  end
end
