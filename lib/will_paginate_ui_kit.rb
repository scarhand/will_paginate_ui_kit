# You will paginate!
module WillPaginateUiKit
end

if defined?(Rails::Railtie)
  require 'will_paginate_ui_kit/railtie'
elsif defined?(Rails::Initializer)
  raise "will_paginate_ui_kit 3.0 is not compatible with Rails 2.3 or older"
end