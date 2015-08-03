app = lambda do |env|
  [200, {}, "Simple Ruby App".lines]
end

run app
