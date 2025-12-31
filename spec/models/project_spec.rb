require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "requested_membership?" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::OWNER) }

    describe "when the user has a pending membership request" do
      let!(:wannabe_collaborator) { FactoryBot.create(:user) }
      let!(:membership_request) { FactoryBot.create(:project_membership_request, project: project, user: wannabe_collaborator) }


      it "returns true if the user has a pending membership request" do
        expect(project.requested_membership?(wannabe_collaborator)).to be true
      end
    end

    describe "when the user does not have a pending membership request" do
      it "returns false if the user does not have a pending membership request" do
        expect(project.requested_membership?(user)).to be false
      end
    end
  end

  describe "collaborator?" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, project: project, user: owner, status: ProjectMembership::ACTIVE, role: ProjectMembership::OWNER) }

    describe "when the user has not project membership" do
      let!(:user) { FactoryBot.create(:user) }

      it "returns false" do
        expect(project.collaborator?(user)).to be false
      end
    end

    describe "when the user has a pending membership request" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:pending_membership) { FactoryBot.create(:project_membership_request, project: project, user: user, status: ProjectMembershipRequest::PENDING) }

      it "returns false" do
        expect(project.collaborator?(user)).to be false
      end
    end

    describe "when the user has a revoked project membership" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project) }
      let!(:revoked_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::REVOKED, role: ProjectMembership::MEMBER) }

      it "returns false" do
        expect(project.collaborator?(user)).to be false
      end
    end

    describe "when the user has an active project membership" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project) }
      let!(:active_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::MEMBER) }

      it "returns true" do
        expect(project.collaborator?(user)).to be true
      end
    end

    describe "when the user has both an active and revoked project membership" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project) }
      let!(:active_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::MEMBER) }

      describe "when the user has both an active and revoked project membership" do
        describe "when the active membership is newer than the revoked one" do
          let!(:active_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::MEMBER) }
          let!(:revoked_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::REVOKED, role: ProjectMembership::MEMBER, created_at: 2.days.ago) }

          it "returns true" do
            expect(project.collaborator?(user)).to be true
          end
        end
      end
    end
  end
end
