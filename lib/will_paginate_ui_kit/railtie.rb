module WillPaginateUiKit
  class Railtie < Rails::Railtie
    initializer "will_paginate_ui_kit" do |app|
      ActiveSupport.on_load :action_view do
        require 'will_paginate_ui_kit/view_helpers/ui_kit_link_renderer'
      end
    end
  end
end
