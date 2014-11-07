# a dummy `index` to demonstrate how requiring `./any/path`
# actually resolves to `./any/path/index` if it exists
module.exports = require 'calc' # this actually loads 'calc/index.js'