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
end
