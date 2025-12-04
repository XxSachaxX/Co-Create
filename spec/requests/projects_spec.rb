require 'rails_helper'

RSpec.describe "Projects", type: :request do
  describe "POST /join" do
    let(:owner) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project) }
    let(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }

    it "allows user to join" do
      expect { post join_project_path(project), params: { email_address: user.email_address, password: "password" } }.
        to change { ProjectMembership.count }.by(1)

      expect(response).to redirect_to(project_path(project))
    end
  end

  describe "POST /leave" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member") }
    before { sign_in user }

    it "allows user to leave" do
      expect { post leave_project_path(project), params: { email_address: user.email_address, password: "password" } }.
        to change { ProjectMembership.count }.by(-1)
      expect(response).to redirect_to(project_path(project))
    end
  end
end
