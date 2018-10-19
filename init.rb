require 'will_paginate_ui_kit'

# This is all duplication of what Railtie does, but is necessary because
# the initializer defined by the Railtie won't ever run when loaded as plugin.

if defined? ActionView::Base
  require 'will_paginate_ui_kit/view_helpers/action_view'
end
