from pithos.plugin import PithosPlugin
from pithos.pithosconfig import get_data_file
import logging

class GrowlPlugin(PithosPlugin):
	preference = 'growl'

	def on_prepare(self):
		pass

	def on_enable(self):
		import gntp.notifier

		#temp hosting of icon
		pithosicon = 'http://puu.sh/xnMA'
		self.growl = gntp.notifier.GrowlNotifier(
			applicationName='Pithos',
			notifications=['State Changed', 'Song Changed'],
			defaultNotifications=['Song Changed'],
			applicationIcon=pithosicon,
			#hostname='localhost',
			#password=''
		)

		self.growl.register()
		self.song_callback_handle = self.window.connect("song-changed", self.song_changed)
		self.state_changed_handle = self.window.connect("user-changed-play-state", self.playstate_changed)

	def playstate_changed(self, window, state):
		if not self.window.is_active():
			if state:
				currstate = 'Playing'
			else:
				currstate = 'Paused'

			try:
				self.growl.notify(
					noteType='State Changed',
					title='Pithos ' + currstate,
					description='',
					icon=pithosicon,
					sticky=False,
					priority=-1
				)
			except:
				logging.warning('Growl not running.')

	def song_changed(self, window, song):
		if not self.window.is_active():
			try:
				self.growl.notify(
					noteType='Song Changed',
					title='Now Playing - %s' %(song.title),
					description='by %s on %s' %(song.artist, song.album),
					icon=pithosicon,
					sticky=False,
					priority=1
				)
			except:
				logging.warning('Growl not running.')


	def on_disable(self):
		self.window.disconnect(self.song_callback_handle)
		# second disconnect errors?!
        #self.window.disconnect(self.state_changed_handle)