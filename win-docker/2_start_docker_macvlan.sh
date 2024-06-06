# see https://www.ipaddressguide.com/cidr
# Beispiel: Zuweisung der IP 192.168.179.223 für den Host und die Schnittstelle vlan-shim
# Diese Befehlszeilen müssen bei jedem Start des System ausgeführt werden,
# beispielsweise über einen Systemd-Dienst.
ip link add vlan-shim link enp3s0 type macvlan mode bridge
ip addr add 192.168.179.223/32 dev vlan-shim
ip link set vlan-shim up
ip route add 192.168.179.208/28 dev vlan-shim