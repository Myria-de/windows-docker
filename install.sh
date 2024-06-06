# Install docker-compose
# sudo apt update
# sudo apt install docker-compose-v2
# Replace "[User]" with your user name
# sudo usermod -aG docker [User]
echo Copy win-docker to /opt/win-docker
#
sudo cp -r win-docker /opt/win-docker
# adjust permissions
sudo chown -R root:docker /opt/win-docker
sudo find /opt/win-docker -type d -exec chmod 775 {} +
sudo find /opt/win-docker -type f -exec chmod 664 {} +
echo Done.
