import moment from 'moment'
import _ from 'lodash'
import {convert} from './dateFormat'

# Format UTC time by passing in the format string.
# The default input parsing format is ISO.
#
# **e.g.** `ll, h:mm:ss a`
export default (opts...) ->
  [time, outputFormat, inputFormat] = _.initial opts
  return unless time
  hbsOpts = _.last opts
  convert time, inputFormat, outputFormat, moment.utc
