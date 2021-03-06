class Projects::ApplicationController < ApplicationController
  before_filter :project
  before_filter :repository
  layout :determine_layout

  def authenticate_user!
    # Restrict access to Projects area only
    # for non-signed users
    if !current_user
      id = params[:project_id] || params[:id]
      project_with_namespace = "#{params[:namespace_id]}/#{id}"
      @project = Project.find_with_namespace(project_with_namespace)

      return if @project && @project.public?
    end

    super
  end

  def determine_layout
    if current_user
      'projects'
    else
      'public_projects'
    end
  end

  def require_branch_head
    unless @repository.branch_names.include?(@ref)
      redirect_to(
        namespace_project_tree_path(@project.namespace, @project, @ref),
        notice: "This action is not allowed unless you are on top of a branch"
      )
    end
  end
end
