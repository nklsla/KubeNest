# Extras
Here are some nice-to-have settings I've used for this project.

## Ubuntu-server specific:
Some aliases for working with kubectl and auto-completion (really useful).<br>
`~/.bashrc`:
```
# Vim
export EDITOR=vim
alias sudoe="sudo -E $EDITOR $@"

# Kubernetes
alias kn="kubectl get nodes -n -all -o wide"
alias kpp="kubectl get pods -A -o wide"
alias kppe="kubectl get pods -A -o wide | grep -v Running"
alias kp="kubectl get pods -o wide"
alias kd="kubectl describe"
alias k=kubectl


source <(kubectl completion bash)
complete -F __start_kubectl k

# SSH
eval "$(ssh-agent)" 1>/dev/null
ssh-add -q ~/.ssh/github
```
For laptop-servers, turn off suspend/sleep when lid is closed by uncomment and change in file <br> `/etc/systemd/logind.conf`:
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
For my main machine, which isn't part of the cluster. I use Manjaro with KDE-plasma.

### SSH colorscheme
Append or create following in file: <br> `~/.ssh/config`
```
PermitLocalCommand yes
Host <alias of server>
    Hostname <ip of server>
    User <log in as user>
    LocalCommand konsoleprofile ColorScheme=<Theme eg. RedOnBlack>;TabColor=#FF0000
```
The above will change the terminal color scheme when connecting to the set host. However, it will not change back. To get around that I set it back by masking `ssh` as a function in my shell, see below.

### zsh scripts
Append this into `~/.zshrc`:
```
# Default
alias l=ls
alias ll="ls -lha"

# SSH
eval "$(ssh-agent)" 1>/dev/null
ssh-add -q /home/nkls/.ssh/github 

# SSH custom colors
# Mask as function, restore ColorScheme on exit
ssh() {/usr/bin/ssh "$@"; konsoleprofile ColorScheme=Breath  }
```

## More
For more details on my vim-setup and the above mentioned files
[see my .dotfiles-repo](https://github.com/nklsla/.dotfiles)
