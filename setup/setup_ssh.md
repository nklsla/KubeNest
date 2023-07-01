# Setup a public SSH service
This will be the nessecary steps to have a secure SSH service exposed to the internet.

__TODO: HOW TO SET UP SSH KEYS. FROM GITHUB?__

## Changes in SSHD config
All the following changes will be done in `/etc/ssh/sshd_config`
### Change Port 22
This is the default port for SSH connections and will always be scanned by bots.
```
Port 33445
```

### Disable Protocol 1
The SSH protocol was updated many years ago from `Protocol 1` to `Protocol 2` and the changes was not backwards compatible. Only allowing `Protocol 2` will protect from vurnebilities in `Protocol 1`.\
Simply add:
```
Protocol 2
```

### Disable password connections
We should only connect using SSH keys, not passwords.
Find and add/change to:
```
PasswordAuthentication no
PermitEmptyPasswords no
```

### Disable X11 and TCP Forwarding
X11 let remote users run graphical apps over SSH from the server. For this project there is not use for that and therefore it should be disabled.
TCP forwarding could potentially expose and security risk too.
```
X11Forwarding no
AllowTcpForwarding no
```

### Disable root login's
Good practise is to not log in as root but use `sudo` when required.

```
PermitRootLogin no
```

## Router port forwarding
To allow a ssh connection and forwarding it from a public IP address, via the router to the server you need to create a port forwarding in your router. This is typically found under the `WAN-settings` or similar. Forward the `WAN` and `LAN` ports to your selected SSH-port and makesure it is forwarding to the correct local ip (the server/master/control-plane node).

You normally access your router by `192.168.1.1` or `192.168.0.1`. See the backside of your router for specifications.

## Create a SSH-key


## Connnect using public ip address
You find your public ip [here](https://www.whatismyip.com) or if you're using VPN, have a look in your routers WAN-settings/status. This setup does not account for a VPN.
```
ssh -p <SSH-port> <usr>@<host_WAN_ip>
```
## Setup a DDNS
Create a free account on [dynu.com](https://www.dynu.com) and create a DDNS service and add your current public IP. Follow their guide under DDNS > Setup to start the `IP Update protocol` for automatic updates when the public IP changes.\

## Extras
In you `~/.ssh/config`
```
PermitLocalCommand yes
Host eva
    Hostname 192.168.1.80
    Port 33445
    User nkls
    LocalCommand konsoleprofile ColorScheme=BlueOnBlack;TabColor=#FF0000

Host eva-remote
    Hostname nkls.kozow.com
    Port 33445
    User nkls
    LocalCommand konsoleprofile ColorScheme=BlueOnBlack;TabColor=#FF0000

```
and connect with `ssh <hostname>`.\
__NOTE: the LocalCommand "konsoleprofile" is specific for zshell__
