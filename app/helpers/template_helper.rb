module TemplateHelper
  def group_templates(templates)
    templates.group_by do |template|
      if template.featured?
        :featured
      elsif current_user && template.user_id == current_user.id
        :yours
      else
        :other
      end
    end
  end
end
