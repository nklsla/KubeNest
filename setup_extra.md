# Extras
Here are some nice-to-have settings but not required.

## Ubuntu-server specific:
`.bashrc`:
```
# Vim
EDITOR=vim

# Kubernetes
alias kp="kubectl get pods -A -o wide"
alias kn="kubectl get nodes -A -o wide"
alias k=kubectl
source <(kubectl completion bash)
complete -F __start_kubectl k
```
For laptop-servers, turn off suspend/sleep when lid is closed by uncomment and change in file `/etc/systemd/logind.conf`
```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```
apply changes with 
```
systemctl restart systemd-logind.service
```


## Manjaro setup
This is for my main machine, which isnt part of the cluster. I use Manjaro with KDE-plasma.

### SSH colorscheme
Append or create following in file: `~/.ssh/config`
```
PermitLocalCommand yes
Host <alias of server>
    Hostname <ip of server>
    User <log in as user>
    LocalCommand konsoleprofile ColorScheme=<Theme eg. RedOnBlack>;TabColor=#FF0000
```
The above will change the terminal color scheme when connecting to the set host. However, it will not change back. To get around that I set it back by masking `ssh` as a function in my shell, see below.\
Append this to `.zshrc`
```
# SSH custom colors
# Mask as function, restore ColorScheme on exit
ssh() {/usr/bin/ssh "$@"; konsoleprofile ColorScheme=Breath  }
```

### Shell scripts
Append this to `.zshrc`
```
# Default
alias l=ls
alias ll="ls -lha"

# SSH
eval "$(ssh-agent)" 1>/dev/null
ssh-add -q /home/nkls/.ssh/github 

# Disable capslock and remap button to 'End'
setxkbmap -option caps:none
xmodmap -e "keycode 66 = End"

# SSH custom colors
# Mask as function, restore ColorScheme on exit
ssh() {/usr/bin/ssh "$@"; konsoleprofile ColorScheme=Breath  }
```

## Add .vimrc
[Upcoming LINK TO dotfiles-repo]()
