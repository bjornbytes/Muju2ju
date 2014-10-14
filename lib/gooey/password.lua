require 'lib/gooey/textfield'

Password = extend(TextField)

Password.renderFilter = function(str) return ('*'):rep(#str) end
