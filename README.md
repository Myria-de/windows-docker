# windows-docker
Install Windows in a docker container

A description of all options is available at https://github.com/dockur/windows.

Enhancements:
- added qemu-system-modules-spice for spice server to the image
- some docker compose files as examples
- added spice options to enable clipboard and audio when using as spice client such as remote-viewer oder Remmina with Spice-Plugin
- systemd service example (autostart docker container)
- Network configuration scripts (example only)

# Docker unter Linux installieren
```
sudo apt install docker-compose-v2
```
```
sudo usermod -aG docker [User]
```
Den Platzhalte „[User]“ ersetzen Sie durch Ihren Benutzernamen. Melden Sie sich bei Linux ab und wieder an, damit die Änderung wirksam wird.

# Windows-Installation starten
Nach der Konfiguration von „docker-compose-win11.yml“ erstellen und starten Sie den Container mit
```
docker compose -f /opt/win-docker/docker-compose-win11.yml up
```
Warten Sie, bis „Windows started succesfully“ erscheint. Im Webbrowser rufen Sie die Adresse „http://localhost:8006“ auf, die mithilfe des Tools noVNC den Windows-Bildschirm anzeigt. 

Wenn Sie Windows herunterfahren, wird der Docker-Container gestoppt und entfernt. Mit der Zeile
```
docker compose -f /opt/win-docker/docker-compose-win11.yml down
```
fahren Sie Windows manuell im Terminal herunter und entfernen den Container. Ersetzen Sie „down“ durch „up“, um den Container wieder zu erzeugen. Die Windows-Installation bleibt erhalten, weil Docker die bisherige virtuelle Festplatte aus dem Ordner „/opt/win-docker/storage“ einbindet. Für ein Backup der Windows-Installation(en) erstellen Sie Sicherungskopien dieses Ordners.

Die Beispieldatei „win11-docker.service“ aus dem Ordner „sytemd-service“ („windows-docker_v4.0.tar.xz“) ermöglicht den Start eines Docker-Containers über den systemd-Dienst. Passen Sie den Inhalt für die verwendete yml-Datei und einen eventuell abweichenden Installationsordnern an. Kopieren Sie die Datei als Benutzer „root“ in den Ordner „/etc/systemd/system“. Aktivieren Sie den Dienst mit
```
sudo systemctl enable win11-docker.service
```
und starten sie ihn mit
```
sudo systemctl start win11-docker.service
```
![203_00_Win_Browser](https://github.com/user-attachments/assets/bd26441e-aeb5-45ad-bdda-32e54ce8c412)
Windows im Docker-Container im Browser über noVNC.

# Zugriff auf den Windows-Desktop
**noVNC** im Browser ist ein VNC-Viewer, der für die Installation und einfache Ansprüche ausreicht, aber keine gemeinsame Zwischenablage und keine Audio-Ausgabe bietet. Das Tool Remote-Viewer kennt diese Mängel nicht. Installieren Sie es über das Paket
```
sudo apt install virt-viewer
```
Nach dem Start geben Sie eine Verbindungsadresse in der Form
```
spice://[Host-IP/Name]:5902
```
ein. Den Platzhalter ersetzen Sie durch die IP-Nummer Ihres Linux-PCs oder seinem Namen im Netzwerk. Remote-Viewer (virt-viewer) ist auch für Windows verfügbar (https://virt-manager.org/download).

**Remmina Remote-Desktop-Client** ist bei Ubuntu standardmäßig installiert ist. Es fehlt aber die Spice-Unterstützung, die Sie mit
```
sudo apt install remmina-plugin-spice
```
nachrüsten. Nutzer von Linux Mint installieren beide Paket auf einmal mit
```
sudo apt install remmina remmina-plugin-spice
```
In Remmina erstellen Sie über das Symbol links oben ein neues Verbindungsprofil. Hinter „Protokoll“ wählen Sie „Spice – Simple Protocol für Independent Computing Environments“ und hinter „Server“ gehört eine Angabe wie
```
[Host-IP/Name]:5902
```
Ein Passwort ist nicht erforderlich. Setzen Sie auf der Registerkarte „Erweitert“ ein Häkchen vor „Audiokanal einschalten“, wenn Sie unter Windows etwas hören möchten. Danach klicken Sie auf „Speichern und verbinden“.
![203_05_Remmina](https://github.com/user-attachments/assets/b48def57-e00d-41e4-adfd-b32d1bec5fd9)
Remmina-Konfiguration im Verbindungsprofil.

**RDP-Clients:** Eine weitere Alternative ist RDP (Remote Desktop Protocol). Die Antwortdatei aktiviert die Remotedesktopverbindung unter Windows Pro oder Enterprise, die Home-Edition bietet diese Funktion nicht. Auch RDP unterstützt eine gemeinsame Zwischenablage und die Audio-Ausgabe.

Das Protokoll lässt sich im Verbindungsprofil von Remmina angeben. Hinter „Server“ tragen Sie
```
[Host-IP/Name]:3389
```
ein. Windows-Nutzer verwenden das Tool Remotedesktopverbindung, das bei allen Windows-Editionen standardmäßig installiert ist.

# Erweiterte Netzwerkkonfiguration
Wer mehrere Windows-Installationen gleichzeitig starten möchte, hat zwei Möglichkeiten. Tragen Sie für jedes weitere Windows in die Konfigurationsdatei für alle Angaben unter „ports:“ abweichende Werte ein, beispielsweise „8007:8006“ für noVNC. Der Webdienst ist dann über „http://localhost:8007“ erreichbar.

Sie können dem System im Docker-Container auch eine IP-Nummer aus dem lokalen Netzwerk zuweisen, womit dessen Port direkt über seine IP erreichbar sind. Windows erhält dann die IP per DHCP vom Router und wird damit ebenfalls in das eigene Netzwerk eingebunden, was den Zugriff auf beliebige Netzwerkfreigaben ermöglicht.

Wie sich das konfigurieren lässt, zeigen zwei Beispielscripte aus dem Ordner „/opt/win-docker“, die Sie vor der Verwendung anpassen. „1_create_docker_macvlan.sh“ erstellt ein zusätzliches Docker-Netzwerk mit der Bezeichnung „vlan“. Tragen Sie IP-Adressen für Ihr Netzwerk ein. Unser Beispiel verwendet das Netzwerk „192.168.179.0“ und definiert den IP-Bereich von 192.168.179.208 bis 192.168.179.223 mit der Zeile
```
--ip-range=192.168.179.208/28
```

Bei der Berechnung der IPs hilft ein Online-Rechner wie https://www.ipaddressguide.com/cidr. Verwenden Sie einen IP-Bereich, den der Router nicht über DHCP vergibt. Eine Fritzbox beispielsweise verwendet standardmäßig nur Adressen bis 192.168.178.200. Die Zeile
```
--aux-address 'host=192.168.179.223'
```
legt eine Hilfsadresse an, die für die Verbindung vom Host-Netzwerk zum Docker-Netzwerk dient. Hinter „parent=“ tragen Sie die Bezeichnung des Netzwerkadapters ein, die Sie im Terminal mit
```
ip a
```
herausbekommen. Das angepasste Script müssen Sie nur einmal starten, um das Docker-Netzwerk zu erzeugen. 
In das Script „2_start_docker_macvlan.sh“ tragen Sie ebenfalls die Bezeichnung des Netzwerkadapters und die IP-Adressen entsprechend der vorherigen Docker-Konfiguration ein. Starten Sie das Script testweise mit
```
sudo sh 2_start_docker_macvlan.sh
```
Damit der Docker-Container die neue Konfiguration verwendet, entfernen Sie in der yml-Datei die Kommentarzeichen („#“) vor den Zeilen für die Netzwerkkonfiguration. Hinter „ipv4_address:“ tragen Sie die erste IP aus dem festgelegten Bereich ein, in unserem Beispiel „192.168.179.208“. In weiteren Windows-Container erhöhen Sie den Wert jeweils um „1“. Starten Sie danach den Container neu.

Durch die neue Konfiguration berücksichtigt Docker die Zuweisungen unter „ports:“ nicht mehr. NoVNC ist im Browser über http://192.168.179.208:8006 erreichbar, der Spice-Server entsprechend über spice://192.168.179.208:5902. Für RDP gilt die IP-Nummer, die Windows per DHCP vom Router erhalten hat.

Für den automatischen Start des Scripts verwenden Sie die Datei „win-docker-macvlan.service“ aus dem Ordner „systemd-service“. Aktivieren und starten Sie den Dienst wie oben für „win11-docker.service“ beschrieben.
