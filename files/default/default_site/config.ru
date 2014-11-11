app = proc do |env|
  [200, { "Content-Type" => "text/html" }, ["Default Rack Site"]]
end
run app