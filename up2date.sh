#!/usr/bin/env bash
# up2date.sh
# Run software update until there are no more updates available.
# @author Filipp Lepalaan
# @package mtk

if [[ $USER != "root" ]]; then
  echo "$(basename $0) must be run as root" 2>&1
  exit 1
fi

ME=$0
PLIST=/Library/LaunchDaemons/com.unflyingobject.mtk.up2date.plist

# updates available...
if /usr/sbin/softwareupdate -l 2>&1 | grep -q 'found the following new'
then
  if [[ ! -e $PLIST ]]; then
    cat > $PLIST <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
  	<key>RunAtLoad</key>
    <true/>
  	<key>Label</key>
  	<string>com.unflyingobject.mtk.up2date</string>
  	<key>ProgramArguments</key>
  	<array>
  		<string>${ME}</string>
  	</array>
  </dict>
</plist>
EOT
  /bin/launchctl load -w $PLIST
  /usr/bin/logger "$(basename $0) loaded"
  exit 0
  fi
  /usr/sbin/softwareupdate -ia && /sbin/reboot
  exit 0
fi

# no more updates available
/bin/launchctl unload -w "${PLIST}" && rm "${PLIST}"
/usr/bin/logger "$(basename $0) unloaded"
exit 0