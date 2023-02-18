# Scripts for automate backup/restore/install on PS4

Steps for use:
 - install HEN (PS4 Homebrew Enabler)
 - Enable build in FTP server
 - Install PKG Installer (https://github.com/flatz/ps4_remote_pkg_installer)

ps4-backups.sh - backup users folder from PS4(savedata trophy username.dat). You can change defaults folders for backup in script.

<table style="align:left;" border="1">
    <tr style="center;">
        <th>Param</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>HOST</td>
        <td>PS4 host</td>
        <td>192.168.1.6</td>
    </tr>
    <tr>
        <td>PORT</td>
        <td>PS4 ftp port</td>
        <td>2121</td>
    </tr>
    <tr>
        <td>BACKUPDIR</td>
        <td>Place where will be stored backup data</td>
        <td>/media/data2/ps4</td>
    </tr>
    <tr>
        <td>CURRDATE</td>
        <td>Format of stored folders</td>
        <td>$(date +"%Y-%m-%d %H:%M")</td>
    </tr>
    <tr>
        <td>BACKUPALL</td>
        <td>Backup all finds users</td>
        <td>true</td>
    </tr>
    <tr>
        <td>FOLDERS</td>
        <td>Folders to backup</td>
        <td>savedata trophy username.dat</td>
    </tr>
</table>

ps4-recovery.sh - restore backup data to PS4(under develop, not work now)

ps4-upload.sh - Upload and install PKGs to PS4(need PKG Installer). Based on server which start on host machine.
I tested with many simple HTTP servers. But worked corrected only on npm http-server. To install them run sudo npm -g install http-server

<table style="align:left;" border="1">
    <tr style="center;">
        <th>Param</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>PS4_HOST</td>
        <td></td>
        <td>192.168.1.6</td>
    </tr>
    <tr>
        <td>PS4_PORT</td>
        <td></td>
        <td>12800</td>
    </tr>
    <tr>
        <td>SERVER_HOST</td>
        <td></td>
        <td>192.168.1.2</td>
    </tr>
    <tr>
        <td>SERVER_PORT</td>
        <td></td>
        <td>8000</td>
    </tr>
    <tr>
        <td>SERVER_HOME</td>
        <td>Base server path where stored pkg</td>
        <td>/media/data2/ps4</td>
    </tr>
</table>