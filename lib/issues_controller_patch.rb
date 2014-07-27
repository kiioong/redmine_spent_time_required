module RedmineSpentTimeRequired
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :update, :check_spent_time
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def update_with_check_spent_time
          allowed_projects = Setting.plugin_redmine_spent_time_required['projects'].scan(/\w+/)
          allowed_statuses = Setting.plugin_redmine_spent_time_required['statuses'].scan(/\d+/)
          current_project = Project.find(params[:issue][:project_id])
          current_status = params[:issue][:status_id]
          if ((!params[:time_entry].nil?) && (!Issue.find(params[:id]).children?))
            if ((params[:time_entry][:hours] == "") && (allowed_projects.member?(current_project.to_param)) && (allowed_statuses.member?(current_status.to_s)))
              find_issue
              update_issue_from_params
              @time_entry.errors.add :hours, :empty
              render(:action => 'edit') and return
            else
              update_without_check_spent_time
            end
          else
            update_without_check_spent_time
          end
        end
      end

    end
  end
end
