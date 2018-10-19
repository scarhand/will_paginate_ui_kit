# will_paginate_ui_kit

Renders [UIKit](https://getuikit.com) compatible pagination component for the [will_paginate](https://github.com/mislav/will_paginate) gem.

## Usage
Add to gemfile.
```
gem 'will_paginate_ui_kit'
```

Use `will_paginate` as you normally would, but set the renderer to the _UiKitLinkRenderer_:
```ruby
<%= will_paginate @posts, renderer: UiKitLinkRenderer %>
```