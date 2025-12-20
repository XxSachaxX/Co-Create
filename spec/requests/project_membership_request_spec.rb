require 'rails_helper'

RSpec.describe ProjectMembershipRequestsController, type: :request do
  describe 'POST #create' do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, user: owner, project: project, role: "owner") }
    let!(:user) { FactoryBot.create(:user) }

    before { sign_in user }

    describe "when user already has a membership request" do
      let!(:membership_request) { FactoryBot.create(:project_membership_request, user: user, project: project) }

      it 'does not create a new project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.not_to change { ProjectMembershipRequest.count }
      end
    end

    describe "when user already has a membership" do
      let!(:membership) { FactoryBot.create(:project_membership, user: user, project: project, role: "member") }

      it 'does not create a new project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.not_to change { ProjectMembershipRequest.count }
      end
    end

    describe "when user does not have a membership request or a membership" do
      it 'creates a new project membership request' do
        expect { post project_membership_requests_path(project_id: project.id) }.to change { ProjectMembershipRequest.count }.by(1)
      end
    end
  end
end
