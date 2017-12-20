import moment from 'moment'
import _ from 'lodash'

# Format time by passing in the format string.
# The default input parsing format is ISO.
#
# **e.g.** `ll, h:mm:ss a`
export default (opts...) ->
  [time, format, inputFormat] = _.initial opts
  return unless time
  hbsOpts = _.last opts
  moment(time, inputFormat or moment.ISO_8601).format(format)
