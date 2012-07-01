# -*- coding: utf-8; tab-width: 4; indent-tabs-mode: nil; -*-
### BEGIN LICENSE
# Copyright (C) 2010-2012 Kevin Mehall <km@kevinmehall.net>
#This program is free software: you can redistribute it and/or modify it 
#under the terms of the GNU General Public License version 3, as published 
#by the Free Software Foundation.
#
#This program is distributed in the hope that it will be useful, but 
#WITHOUT ANY WARRANTY; without even the implied warranties of 
#MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR 
#PURPOSE.  See the GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License along 
#with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE

from pithos.plugin import PithosPlugin
import logging
try:
    import pyHook
except ImportError:
    logging.warning('Please install PyHook(http://sourceforge.net/projects/pyhook/files/')

class MediaKeyPlugin(PithosPlugin):
    preference = 'mediakeys'

    def kbevent(self, event):
        if event.KeyID == 179 or event.Key == 'Media_Play_Pause':
            self.window.playpause_notify()
        if event.KeyID == 176 or event.Key == 'Media_Next_Track':
            self.window.next_song()
        return True
        
    def on_enable(self):
        self.hookman = pyHook.HookManager()
        self.hookman.KeyDown = self.kbevent
        self.hookman.HookKeyboard()
        
    def on_disable(self):
        self.hookman.UnhookKeyboard()
