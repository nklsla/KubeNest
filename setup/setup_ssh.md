# Setup SSH
Setup guide for hosting a `ssh`-service to be securly accessible locally and publicly. This will be the necessary for working with a headless server cluster as this repository aims to do.
<!--toc-->

- [Install and enable SSH service](#install-and-enable-ssh-service)
- [Setup keypair and authentication](#setup-keypair-and-authentication)
- [Security changes in SSHD config](#security-changes-in-sshd-config)
    + [Change default port](#change-default-port)
    + [Disable Protocol 1](#disable-protocol-1)
    + [Disable password connections](#disable-password-connections)
    + [Disable X11 and TCP Forwarding](#disable-x11-and-tcp-forwarding)
    + [Disable root login](#disable-root-login)
    + [sshd_config](#sshd_config)
- [Connnect with public IP](#connnect-with-public-ip)
  * [Router port forwarding](#router-port-forwarding)
  * [Setup a Dynamic Domain Name System (DDNS)](#setup-a-dynamic-domain-name-system-ddns)
- [Extras](#extras)

## Install and enable SSH service
Make sure `ssh`-service is installed and enabled for autostart. This comes out of the box in `ubuntu server`.
```
sudo apt update
sudo apt install openssh-server

# Start and enable the service to autostart on startup
sudo systemctl enable ssh

# Verify if started and enabled
systemctl status ssh
```

## Setup keypair and authentication
A good and detailed explanation from _Digital Ocean_ about this topic is [found here](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server).
This guide covers everything and is well written, therefore do I see no point in writing a lesser copy.

## Security changes in SSHD config
All the following changes will be done in `/etc/ssh/sshd_config` on __every machine__ that acts as `ssh`-hosts. These settings are mostly relevant if the machine is publicly exposed (i.e. internet). <br> 
Your router will block any public traffic unless you've opened port `22` for the specific machine. However, for the uniformity this could be applied for all nodes, especially the port since there are some automatic `ssh`-commands during the initiation phase when starting the cluster ([kub-init.sh](../kub-init.sh)).

#### Change default port 22
This is the default port for `ssh`-connections and are constantly scanned by bots on the public internet. Changing this will at least remove that risk. In `/etc/ssh/sshd_config` change:
```
Port <your ssh port>
```
In this setup the _Uncomplicated Firewall_ (`ufw`) is enabled, which means this port has to be allowed before it is used, see [firewall setup](setup_firewall.sh). \
For public exposure, this port has to be open in your [router as well](#router-port-forwarding).

#### Disable Protocol 1
The `ssh`-protocol was updated many years ago from `Protocol 1` to `Protocol 2` and the changes were not backwards compatible. Only allowing `Protocol 2` will protect from vulnerabilities in `Protocol 1`.\
Simply add:
```
Protocol 2
```

#### Disable password connections
Allowing only `keys` greatly increases security from brute-force attacks.
Find and add/change:
```
PasswordAuthentication no
PermitEmptyPasswords no
```

#### Disable X11 and TCP Forwarding
X11 let remote users run graphical apps over SSH from the server. For this setup there is not use for that and therefore it should be disabled. `tcp` forwarding could potentially expose and security risk too.
```
X11Forwarding no
AllowTcpForwarding no
```

#### Disable root login
As always, a good practise is to not log in as root but use `sudo` when required.

```
PermitRootLogin no
```

#### sshd_config
<details>
<summary>See the full file here </summary>
    
```
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf
Protocol 2

#Port 22
Port 33445
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
PermitRootLogin no
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
KbdInteractiveAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
AllowTcpForwarding no
#GatewayPorts no
X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem       sftp    /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server

```
</details>


## Connnect with public IP 
You find your public ip at [whatismyip.com](https://www.whatismyip.com) or if you're using VPN, have a look in your routers WAN-settings/status. This setup __does not__ account for a VPN.
```
ssh -p <SSH-port> <usr>@<host_WAN_ip>
```

### Router port forwarding
To allow a `ssh`-connection and forwarding it from a public IP address, via the router to the host machine you need to create a port forwarding in your router. This is typically found under the `WAN-settings` or similar. Forward the `WAN` and `LAN` ports to your selected `ssh`-port and make sure it is forwarding to the correct local IP (the `control-plane` node in this case).

Normally a router is accessed from `192.168.1.1` or `192.168.0.1`. See the backside of your router for specifications.
### Setup a Dynamic Domain Name System (DDNS)
Unless you have a static IP-address from your internet service provider (ISP) you'll have to keep track of your IP-address to connect over the internet. To automate this there is DDNS.\
- Create a free account on [dynu.com](https://www.dynu.com) and create a DDNS service and add your current public IP. 
- Follow their guide under DDNS > Setup to start the `IP Update protocol` for automatic updates when the public IP changes.\

## Extras
For ease of access you can setup aliases for your `ssh-client`

In you `~/.ssh/config`
```
PermitLocalCommand yes
Host <host alias>
    Hostname 192.168.1.80
    Port 33445
    User <USERNAME>
    LocalCommand konsoleprofile ColorScheme=BlueOnBlack;TabColor=#FF0000

Host <host alias>-remote
    Hostname <DDNS>
    Port 33445
    User <USERNAME>
    LocalCommand konsoleprofile ColorScheme=BlueOnBlack;TabColor=#FF0000

```
and connect with `ssh <hostname>`.\
__NOTE: the LocalCommand "konsoleprofile" is specific for the `konsole`-terminal (native in KDE plasma)__
