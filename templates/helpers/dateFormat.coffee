import moment from 'moment'

export convert = (time, inputFormat, outputFormat, func = moment) ->
  func(time, inputFormat or moment.ISO_8601).format outputFormat

# Format time by passing in the format string.
# The default input parsing format is ISO.
#
# **e.g.** `ll, h:mm:ss a`
export default (opts...) ->
  [time, outputFormat, inputFormat] = _.initial opts
  return unless time
  hbsOpts = _.last opts
  convert time, inputFormat, outputFormat
