require 'rails_helper'

RSpec.describe "ProjectMemberships", type: :request do
  describe "POST #revoke" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner", status: "active") }
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member", status: "active") }

    before { sign_in owner }

    it "revokes the membership" do
      expect {
        post revoke_project_membership_path(user_membership)
      }.to change { user_membership.reload.status }.from("active").to("revoked")
    end
  end
end
