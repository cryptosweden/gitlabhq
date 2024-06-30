# frozen_string_literal: true

module Organizations
  class OrganizationsController < ApplicationController
    include PreviewMarkdown
    include FiltersEvents

    DEFAULT_RESOURCE_LIMIT = 1000
    DEFAULT_ACTIVITY_EVENT_LIMIT = 20

    feature_category :cell

    before_action :event_filter, only: [:activity]
    before_action :authorize_read_organization!, only: [:activity, :show, :groups_and_projects]
    before_action only: [:index] do
      push_frontend_feature_flag(:allow_organization_creation, current_user)
    end

    skip_before_action :authenticate_user!, only: [:activity, :show, :groups_and_projects]

    urgency :low, [:activity]

    def index; end

    def new
      authorize_create_organization!
    end

    def show; end

    def activity
      respond_to do |format|
        format.html
        format.json do
          load_events
          # load_events queries for limit + 1.
          # This will be removed as part of https://gitlab.com/gitlab-org/gitlab/-/issues/382473
          has_next_page = @events.length > activity_query_limit
          @events.pop if has_next_page

          @events = @events.select { |event| event.visible_to_user?(current_user) }

          render json: \
            { events: ::Profile::EventSerializer.new(current_user: current_user).represent(@events), \
              has_next_page: has_next_page }
        end
      end
    end

    def groups_and_projects; end

    def users
      authorize_read_organization_user!
    end

    private

    def activity_query_limit
      return params[:limit].to_i unless !params[:limit] || params[:limit].to_i > DEFAULT_ACTIVITY_EVENT_LIMIT

      DEFAULT_ACTIVITY_EVENT_LIMIT
    end

    def load_events
      @events = EventCollection.new(
        organization.projects.limit(DEFAULT_RESOURCE_LIMIT).sorted_by_activity,
        offset: params[:offset].to_i,
        filter: event_filter,
        # limit + 1 allows us to determine if we have another page.
        # This will be removed as part of https://gitlab.com/gitlab-org/gitlab/-/issues/382473
        limit: activity_query_limit + 1,
        groups: organization.groups.limit(DEFAULT_RESOURCE_LIMIT)
      ).to_a.map(&:present)

      Events::RenderService.new(current_user).execute(@events)
    end
  end
end
