ActionController::Renderers.add :csv do |csv, options|
  self.content_type ||= Mime::CSV
  self.response_body  = csv.respond_to?(:to_csv) ? csv.to_csv : csv
end
