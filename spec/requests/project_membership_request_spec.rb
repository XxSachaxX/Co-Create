require 'rails_helper'

RSpec.describe ProjectMembershipRequestsController, type: :request do
  describe 'POST #create' do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let!(:user) { FactoryBot.create(:user) }

    before { sign_in user }

    describe "when user already has a pending membership request" do
      let!(:membership_request) { FactoryBot.create(:project_membership_request, user: user, project: project, status: ProjectMembershipRequest::PENDING) }

      it 'does not create a new project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.not_to change { ProjectMembershipRequest.count }
      end
    end

    describe "when user has a rejected membership request" do
      let!(:membership_request) { FactoryBot.create(:project_membership_request, user: user, project: project, status: ProjectMembershipRequest::REJECTED) }

      it 'creates a new pending project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.to change { ProjectMembershipRequest.count }.by(1)
      end
    end

    describe "when user already has a membership" do
      let!(:membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member") }

      it 'does not create a new project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.not_to change { ProjectMembershipRequest.count }
      end
    end

    describe "when user does not have a membership request or a membership" do
      it 'creates a new pending project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.to change { ProjectMembershipRequest.count }.by(1)
      end
    end
  end

  describe "POST #accept" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let!(:user) { FactoryBot.create(:user) }
    let!(:membership_request) { FactoryBot.create(:project_membership_request, user: user, project: project) }

    describe "when user is not the owner" do
      before { sign_in user }

      it "raises an error" do
        expect { post accept_project_membership_request_path(membership_request) }.to raise_error { ProjectMembershipRequestsController::RestrictedToOwnerError }
      end
    end

    describe "when user is the owner" do
      before { sign_in owner }

      it "does not raise an error" do
        expect { post accept_project_membership_request_path(membership_request) }.not_to raise_error { ProjectMembershipRequestsController::RestrictedToOwnerError }
      end

      it "marks the request as accepted" do
        expect { post accept_project_membership_request_path(membership_request) }.to change { membership_request.reload.status }.from("pending").to("accepted")
      end

      it "creates a new project membership" do
        expect { post accept_project_membership_request_path(membership_request) }.to change { ProjectMembership.count }.by(1)
        expect(user.project_memberships.count).to eq(1)
      end
    end
  end

  describe "POST #reject" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let!(:user) { FactoryBot.create(:user) }
    let!(:membership_request) { FactoryBot.create(:project_membership_request, user: user, project: project) }

    describe "when user is not the owner" do
      before { sign_in user }

      it "raises an error" do
        expect { post reject_project_membership_request_path(membership_request) }.to raise_error { ProjectMembershipRequestsController::RestrictedToOwnerError }
      end

      describe "when user is the owner" do
        before { sign_in owner }

        it "does not raise an error" do
          expect { post reject_project_membership_request_path(membership_request) }.not_to raise_error { ProjectMembershipRequestsController::RestrictedToOwnerError }
        end

        it "marks the request as rejected and does not create a new project membership" do
          expect { post reject_project_membership_request_path(membership_request) }.to change { membership_request.reload.status }.from("pending").to("rejected")
          expect(ProjectMembership.count).to eq(1)
        end
      end
    end
  end
end
