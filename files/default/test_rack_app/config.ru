app = proc do |env|
  [200, { "Content-Type" => "text/html" }, ["Test Rack App"]]
end
run app