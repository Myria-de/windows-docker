#see https://www.ipaddressguide.com/cidr
# Mit ip a bekommen Sie die Bezeichung der Netzwerkschnittstelle heraus
# In unserem Beispiel enp3s0.
# Beispiel: Router vergibt per DHCP Adressen bis 192.168.179.200
# 192.168.179.0/24 steht für den gesamten Bereich von 192.168.179.0 bis 192.168.179.255
# Mit --iprange 192.168.179.208/28 begrenzen wir den Bereich auf 192.178.179.208 bis 192.168.179.223
# --aux-address reserviert die IP 192.168.179.223 für den Host
# Die Netzwerkschnittstelle für Docker heißt vlan.
docker network create -d macvlan \
    --subnet=192.168.179.0/24 \
    --gateway=192.168.179.1 \
    --ip-range=192.168.179.208/28 \
    --aux-address 'host=192.168.179.223' \
    -o parent=enp3s0 vlan
