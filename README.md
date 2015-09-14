nfsub
=====

Subtitles for Netflix

### Disclaimer

This script is in no way affiliated or endorsed by Netflix. Use at your own peril.

Motivation
----------

My boyfriend is British and near deaf. Swedish Netflix provide only
nordic language subtitles for most content. However, the internet is
full of `.srt` subtitles for almost everything. This plugin lets me
load .srt subtitles into a netflix movie and watch Netflix together
with my boyf.

Installation
------------

### Using tampermonkey

1. Install [tampermonkey](https://tampermonkey.net/)
2. Install the <a href="https://raw.githubusercontent.com/algesten/nfsub/master/nfsub.user.js" target="_blank">nfsub script</a> by clicking this link *after* tampermonkey is installed.
3. Start playing a Netflix movie
4. In the subtitle menu, there's a "Load" button
5. Load your local .srt-file
6. Adjust timings with G and H (like VLC)

Example
-------

The load button is in the subtitles menu.

![The Load button](https://cloud.githubusercontent.com/assets/227204/7842098/b5194444-04a9-11e5-9d2f-ed5db2981cbc.png)

Subtitle are loaded and timings adjusted with G and H (like VLC). But not in fullscreen.

![example](https://cloud.githubusercontent.com/assets/227204/7879635/dc8417f0-05fa-11e5-84ad-6ce386cf324d.png)

Keys in fullscreen
------------------

Due to security restrictions in HTML5 video, we can't capture keyboard
events when in fullscreen. To adjust timings, exit fullscreen and then
adjust.

License
-------

The MIT License (MIT)

Copyright © 2015 Martin Algesten

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
