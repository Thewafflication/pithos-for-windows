from pithos.plugin import PithosPlugin
from pithos.pithosconfig import get_data_file
import logging

class GrowlPlugin(PithosPlugin):
	preference = 'growl'

	def on_prepare(self):
		pass

	def on_enable(self):
		try: import gntp.notifier
		except(ImportError):
			logging.error('Growl Error: gntp not installed: https://github.com/kfdm/gntp')
			return False
		#temp hosting of icon
		self.pithosicon = 'http://puu.sh/xnMA'
		self.growl = gntp.notifier.GrowlNotifier(
			applicationName='Pithos',
			notifications=['Song Changed'],
			defaultNotifications=['Song Changed'],
			applicationIcon=self.pithosicon,
			# change for over the network notifications
			#hostname='localhost',
			#password=''
		)
		try: self.growl.register()
		except: logging.warning('Failed to register Growl')
		self.song_callback_handle = self.window.connect("song-changed", self.song_changed)

	def song_changed(self, window, song):
		try:
			self.growl.notify(
				noteType='Song Changed',
				title=song.title,
				description='by %s on %s' %(song.artist, song.album),
				icon=self.pithosicon,
				sticky=False,
				priority=1
			)
		except:
			logging.warning('Growl not running')

	def on_disable(self):
		self.window.disconnect(self.song_callback_handle)
