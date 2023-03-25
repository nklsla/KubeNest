# Setup SSH for internet
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

## Create a SSH-key
