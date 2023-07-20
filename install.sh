#!/bin/sh

# DD-WRT Home Assistant Installer
# Copyright © 2019 Mateusz Dera

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

# Optware-ng

echo -e "\e[92;1;48;5;239m ===================================== \e[0m"
echo -e "\e[92;1;48;5;240m |  DD-WRT HOME ASSISTANT INSTALLER  | \e[0m"
echo -e "\e[92;1;48;5;241m |  \e[94;1;48;5;241mMateusz Dera  \e[92;1;48;5;241m                   | \e[0m"
echo -e "\e[92;1;48;5;240m | \e[94;1;48;5;240m Version:\e[92;1;48;5;240m 1.3.1                  | \e[0m"
echo -e "\e[92;1;48;5;239m ===================================== \e[0m"

mount --bind /jffs/ /opt/

if ! [ -d "/jffs/.tmp" ]; then
   mkdir /jffs/.tmp || exit 1
fi
cd /jffs/.tmp || exit 1
curl -kLO https://raw.githubusercontent.com/Mateusz-Dera/DD-WRT-Easy-Optware-ng-Installer/master/install.sh || exit 1
sh ./install.sh -s 
/opt/bin/ipkg update || exit 1
rm -R /jffs/.tmp || exit 1

cd /jffs/opt || exit 1

# Install
/opt/bin/ipkg install gcc || exit 1
/opt/bin/ipkg install make || exit 1
/opt/bin/ipkg install busybox || exit 1
/opt/bin/ipkg install python3 || exit 1
/opt/bin/ipkg install openssl-dev || exit 1

# Python
python3 -m venv --without-pip homeassistant || exit 1
source homeassistant/bin/activate || exit 1
curl -k https://bootstrap.pypa.io/get-pip.py -o get-pip.py || exit 1
python3 /opt/get-pip.py && rm /opt/get-pip.py || exit 1

if ! [ -d "/opt/homeassistant/config" ]; then
   mkdir /opt/homeassistant/config || exit 1
fi

pip install --upgrade pip || exit 1
python3 -m pip install PyNaCl==1.3.0 || exit 1
python3 -m pip install hass-nabucasa==0.12 || exit 1
python3 -m pip install sqlalchemy==1.0.0 || exit 1
python3 -m pip install homeassistant==0.92.1 || exit 1

# Autostart
cd /jffs/etc/config || exit 1
[ -f ./hass.startup ] && rm hass.startup
[ -f ./hass.startup ] && exit 1
echo -e '#!/bin/sh\n/usr/bin/logger -t START_$(basename $0) "started [$@]"\nSCRLOG=/tmp/$(basename $0).log\ntouch $SCRLOG\nTIME=$(date +"%Y-%m-%d %H:%M:%S")\necho $TIME "$(basename $0) script started [$@]" >> $SCRLOG\nsource /opt/homeassistant/bin/activate\npython3 -c "import sqlite3"\nhass --config /opt/homeassistant/config \nTIME=$(date +"%Y-%m-%d %H:%M:%S")\nif [ "$?" -ne 0 ]\nthen\necho $TIME "Error in script execution! Script: $0" >> $SCRLOG\nelse\necho $TIME "Script execution OK. Script: $0" >> $SCRLOG\nfi\n/usr/bin/logger -t STOP_$(basename $0) "return code $?"\nexit $?' > hass.startup || exit 1
[ -f ./hass.startup ] || exit 1
chmod 700 hass.startup || exit 1

echo -e "Installation complete!\nRestart router"
