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

mkdir /jffs/opt && mount -o bind /jffs/opt /opt
cd /opt
wget -O - http://pkg.entware.net/binaries/armv7/installer/entware_install.sh | /bin/sh 
opkg update
opkg upgrade 
opkg install nano 
opkg install python3-dev 
cd /opt
python3 -m venv --without-pip homeassistant
source homeassistant/bin/activate 
curl -k https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 /opt/get-pip.py && rm /opt/get-pip.py
pip3 install netifaces
pip3 install warrant==0.6.1
HOME=/opt/ha/ python3 -m pip install homeassistant==0.75.3
hass --config /opt/ha/
