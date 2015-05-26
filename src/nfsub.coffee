subplay = require 'subplay'

mkel    = (n) ->  document.createElement n
byTag   = (tg) -> document.getElementsByTagName(tg)?[0]
byClass = (cl) -> document.getElementsByClassName(cl)?[0]

CNAME = 'player-timedtext'

# helper function to get video tag
getVideo  = -> byTag 'video'
getOutput = ->
  el = byClass 'nfsub-text'
  return el if el
  # this is where nf places their subtitles
  sib = byClass CNAME
  el = mkel 'div'
  el.className = CNAME
  # append all into DOM
  sib.parentNode.appendChild el
  # receive click on the element
  el.addEventListener 'click', onOutputClick
  el.style.background = 'blue' # xxx
  el.style.position = 'absolute'
  el.style.bottom = '50px'
  el.style.left = 0
  el.style.height = '100px'
  el.style.width = '100%'
  el


onOutputClick = (ev) ->
  el = ev.target
  # append file input used to load srt
  iel = mkel 'input'
  iel.type = 'file'
  # the event listener for reading srt
  iel.addEventListener 'change', readFile, false
  el.appendChild iel
  # simulate click
  iel.click()


# the handler for change events which reads a srt-file
# and starts the subplay player.
readFile = (evt) ->
  f = evt.target.files?[0]
  return unless f
  r = new FileReader()
  r.onload = (e) ->
    srt = e.target.result
    nfsub.start srt
  r.readAsText(f)


# the initial <video> tag is inert and any event handlers
# added to it are not working. this function installs an event
# listener every second and only when it actually fires
# does it add the actual onTimeUpdate() handler.
installEventListener = ->
  videoEl = null
  if videoEl
    videoEl.removeEventListener 'timeupdate', onTimeUpdate
  receivedTimeupdate = ->
    clearInterval inter # stop installing
    videoEl.removeEventListener 'timeupdate', receivedTimeupdate # remove self
    videoEl.addEventListener 'timeupdate', onTimeUpdate # install real
    setOutput true, 'click to load subtitles'
  inter = setInterval ->
    videoEl = getVideo()
    if videoEl
      videoEl.addEventListener 'timeupdate', receivedTimeupdate
  , 1000


window.addEventListener 'load', installEventListener


# the update function or -> if inert
update = ->

# wire video update events to the update function
onTimeUpdate = (ev) -> update ev.target.currentTime

# render function that places the text on screen
renderer = (text) ->
  setOutput false, text

setOutput = (loadMode, text) ->


module.exports = nfsub =
  start: (srt) -> update = subplay(srt, renderer)
  stop:        -> update = ->
