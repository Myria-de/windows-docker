# Windows über einen Container starten
Install Windows in a docker or podman container

A description of all options is available at https://github.com/dockur/windows.

Enhancements:
- added qemu-system-modules-spice for spice server to the image
- some docker compose files as examples
- added spice options to enable clipboard and audio when using as spice client such as remote-viewer oder Remmina with Spice-Plugin
- systemd service example (autostart docker container)
- Network configuration scripts (example only)


# Nutzung mit Podman (rootless)
Zur Installation von Podman (rootless) in einer aktuellen Version siehe https://github.com/Myria-de/podman.

Gegenüber der Nutzung von Docker (non-rootless) ergeben sich einige Nachteile. Das Windows-Netzwerk ist mit NAT konfiguriert. Ein Zugriff auf das lokale Netzwerk ist nicht möglich. Für den Datenaustausch mit dem Host können Sie aber einen gemeinsamen Ordner nutzen. Die für Docker beschriebene Netzwerkkonfiguration mit DHCP und einer eigenen IP für Windows erfordert höhere Rechte.

Für die Einrichtung erstellen Sie in Ihrem Home-Verzeichnis einen Arbeitsordner:
```
mkdir ~/win-docker
```
Kopieren Sie aus "podman-compose" die Datei podman-compose-rootless-win10.yml oder podman-compose-rootless-win11.yml in diesen Ordner.

Erstellen Sie den Ordner "~/win-docker/shared" für den Dateiaustausch.

Öffnen Sie die YML-Datei in einem Editor und passen Sie beispielweise die Werte unter "environment" nach Wunsch an.

Unter "volumes:" sind die Pfade in Ihr Homeverzeichnis konfiguriert. "$HOME/win-docker/Win10_22H2_German_x64v1.iso:/boot.iso" verweist auf die ISO-Datei für die Windows-Installation. Laden Sie die gewünschte Datei bei Microsoft herunter: https://tinyurl.com/dw11iso (Windows 11) oder https://tinyurl.com/dw10iso (Windows 10). Kommentieren Sie die Zeile aus, wenn Podman die ISO-Datei selbst herunterladen soll.

Erstellen und starten Sie den Podman-Container im Terminal mit
```
cd ~/win-docker
podman compose -f podman-compose-rootless-win10.yml up
```
Warten Sie, bis „Windows started succesfully“ erscheint. Im Webbrowser rufen Sie die Adresse „http://localhost:8006“ auf, die mithilfe des Tools noVNC den Windows-Bildschirm anzeigt. Nach der Installation verwenden Sie beispielsweise Remmina, wie weiter unten unter "Zugriff auf den Windows-Desktop" beschrieben. 

# Nutzung mit Docker

## Docker unter Linux installieren
```
sudo apt install docker-compose-v2
```
Die weiteren für Docker nötigen Pakete wie docker.io werden automatisch installiert.
```
sudo usermod -aG docker [User]
```
Den Platzhalte „[User]“ ersetzen Sie durch Ihren Benutzernamen. Melden Sie sich bei Linux ab und wieder an, damit die Änderung wirksam wird.

## Windows-Installation starten
Verwenden Sie das Script "install.sh", um die relevanten Dateien nach "/opt/win-docker" zu kopieren. 

Nach der Konfiguration von „docker-compose-win11.yml“ erstellen und starten Sie den Container mit
```
cd /opt/win-docker
docker compose -f docker-compose-win11.yml up
```
Warten Sie, bis „Windows started succesfully“ erscheint. Im Webbrowser rufen Sie die Adresse „http://localhost:8006“ auf, die mithilfe des Tools noVNC den Windows-Bildschirm anzeigt. 

Wenn Sie Windows herunterfahren, wird der Docker-Container gestoppt. Im Terminal können Sie den Container auch mit Strg-C stoppen.

Verwenden Sie 
```
docker compose -f /opt/win-docker/docker-compose-win11.yml up
```
erneut, um Windows zu starten.

Die Windows-Installation bleibt erhalten, weil Docker die bisherige virtuelle Festplatte aus dem Ordner „/opt/win-docker/storage“ einbindet. Für ein Backup der Windows-Installation(en) erstellen Sie Sicherungskopien dieses Ordners.

Die Beispieldatei „win11-docker.service“ aus dem Ordner „systemd-service“ermöglicht den Start eines Docker-Containers über den systemd-Dienst. Passen Sie den Inhalt für die verwendete yml-Datei und einen eventuell abweichenden Installationsordnern an. Kopieren Sie die Datei als Benutzer „root“ in den Ordner „/etc/systemd/system“. Aktivieren Sie den Dienst mit
```
sudo systemctl enable win11-docker.service
```
und starten sie ihn mit
```
sudo systemctl start win11-docker.service
```
![203_00_Win_Browser](https://github.com/user-attachments/assets/bd26441e-aeb5-45ad-bdda-32e54ce8c412)
Windows im Docker-Container im Browser über noVNC.

**Hiweise:** Das System und die Programme im Docker-Container laufen unter dem Benutzerkonto "root". Alle Dateien, die unter "/opt/win-docker" neu erstellt oder verändert werden, gehören ebenfalls dem Benutzer "root". Wenn Sie Schreibzugriff auf einen der Ordner benötigen, verwenden Sie "sudo" im Terminal. Oder Sie ändern die Rechte mit
```
sudo chown -R root:docker /opt/win-docker
sudo find /opt/win-docker -type d -exec chmod 775 {} +
sudo find /opt/win-docker -type f -exec chmod 664 {} +
```
Als Mitglied der Gruppe "docker" erhalten Sie Schreibzugriff. Die Rechte ändern sich jedoch wieder, etwa wenn Sie unter Windows Dateien im Ordner für den Datenaustausch erstellen ("Netzwerk -> host.lan").

## Zugriff auf den Windows-Desktop
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

## Erweiterte Netzwerkkonfiguration
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

Das Docker Netzwerk "vlan" ist standardmäßig nicht auf dem Rechner erreichbar, auf dem der Container läuft. Von anderen Rechnern im Netzwerk funktioniert der Zugriff. Um das zu ändern, verwenden Sie das Script „2_start_docker_macvlan.sh“. Hier tragen Sie ebenfalls die Bezeichnung des Netzwerkadapters und die IP-Adressen entsprechend der vorherigen Docker-Konfiguration ein. Starten Sie das Script testweise mit
```
sudo sh 2_start_docker_macvlan.sh
```
Die Beispieldate "docker-compose-win11-vlan.yml" zeigt die Konfiguration des Container. Hinter „ipv4_address:“ tragen Sie die erste IP aus dem festgelegten Bereich ein, in unserem Beispiel „192.168.179.208“. In weiteren Windows-Container erhöhen Sie den Wert jeweils um „1“. Starten Sie danach den Container neu.

Durch die neue Konfiguration berücksichtigt Docker die Zuweisungen unter „ports:“ nicht mehr. NoVNC ist im Browser über http://192.168.179.208:8006 erreichbar, der Spice-Server entsprechend über spice://192.168.179.208:5902. Für RDP gilt die IP-Nummer, die Windows per DHCP vom Router erhalten hat.

Für den automatischen Start des Scripts verwenden Sie die Datei „win-docker-macvlan.service“ aus dem Ordner „systemd-service“. Aktivieren und starten Sie den Dienst wie oben für „win11-docker.service“ beschrieben.

