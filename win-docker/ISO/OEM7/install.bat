@echo off
cd /D c:\oem
msiexec /i "qemu-ga-x86_64.msi" /qn ADDLOCAL=ALL

