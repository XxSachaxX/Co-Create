require 'rails_helper'

RSpec.describe "ProjectMemberships", type: :request do
  describe "POST #revoke" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner", status: "active") }
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member", status: "active") }

    before { sign_in owner }

    describe "when logged in as an unrelated user" do
      let(:random_user) { FactoryBot.create(:user) }

      before { sign_in random_user }
      describe "when trying to revoke a membership" do
        it "raises an error" do
          expect {
            post revoke_project_membership_path(user_membership)
          }.to raise_error(ProjectMembershipsController::RestrictedToOwnerError)
        end
      end
    end

    describe "when logged in as a regular member of the project" do
      let(:project_member) { FactoryBot.create(:user) }
      let!(:project_member_membership) { FactoryBot.create(:project_membership, user: project_member, project: project, role: "member", status: "active") }

      before { sign_in project_member }
      describe "when trying to revoke a membership" do
        it "raises an error" do
          expect {
            post revoke_project_membership_path(user_membership)
          }.to raise_error(ProjectMembershipsController::RestrictedToOwnerError)
        end
      end
    end

    describe "when logged in as the owner" do
      describe "when trying to revoke a membership" do
        it "revokes the membership" do
          expect {
            post revoke_project_membership_path(user_membership)
          }.to change { user_membership.reload.status }.from("active").to("revoked")
        end

        it "redirects to the project's page" do
          post revoke_project_membership_path(user_membership)

          expect(response).to redirect_to(project_path(project))
        end
      end
    end
  end
end
