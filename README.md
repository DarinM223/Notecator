Notecator
==============

An iOS app that allows you to take location based notes 

### Setting up the project

First you have to install the CocoaPods for this project by running
```
pod install
```
inside the main project folder (once you have CocoaPods installed).

Then you have to set up the Parse API keys. First you have to create your Parse application online. 
Then inside the main folder, go to the location-notes directory and create a Keys.plist file with the following:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>parseApplicationId</key>
	<string>*** Enter Parse application id here ***</string>
	<key>parseClientKey</key>
	<string>*** Enter Parse client key here ***</string>
</dict>
</plist>
```

You also have to create a Facebook application for this project so that Facebook login works.

