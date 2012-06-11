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

class MediaKeyPlugin(PithosPlugin):
    preference = 'enable_mediakeys'
    
    def bind_keybinderwin32(self):
        try: 
            import win32api
        except ImportError:
            return False
        
        play_pause = win32api.MapVirtualKey(0xB3, 0)
        next_button = win32api.MapVirtualKey(0xB0, 0)

        while True:
            if win32api.GetKeyState(play_pause) == 1:
                self.window.playpause()

            if win32api.GetKeyState(next_button) == 1:
                self.window.next_song()

        return True
        
    def on_enable(self):
        pass #not working atm
        #self.bind_keybinderwin32()
        
    def on_disable(self):
        logging.error("Not implemented: Can't disable media keys")
