require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let!(:owner) { FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project) }
  let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
  let!(:user) { FactoryBot.create(:user) }
  describe "POST /join" do

    before { sign_in user }

    it "allows user to join" do
      expect { post join_project_path(project), params: { email_address: user.email_address, password: "password" } }.
        to change { ProjectMembership.count }.by(1)

      expect(response).to redirect_to(project_path(project))
    end
  end
end
