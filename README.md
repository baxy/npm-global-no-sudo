npm-global-no-sudo
==================

This script fixes the issues encountered when you are required to use 'sudo' to install npm global packages.
The fix consists in creating a new local directory for global packages (default: ~/.npm-packages), configure node to use it and fix permissions.
Existing global packages will be backed up and reinstalled after the fix.

The script is an improved version of [npm-g_nosudo](https://github.com/glenpike/npm-g_nosudo), based on the guide [npm-global-without-sudo](https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md).

### Usage:

##### Download:
```
wget https://raw.githubusercontent.com/baxy/npm-global-no-sudo/master/npm-global-no-sudo.sh
```
or
```
curl -O https://raw.githubusercontent.com/baxy/npm-global-no-sudo/master/npm-global-no-sudo.sh
```

##### Make executable:
```
chmod +x npm-global-no-sudo.sh
```

##### Run:
```
./npm-global-no-sudo.sh
```

### Important

1. After updating your environment files, you will need to [source](http://ss64.com/bash/source.html) the corresponding file before your npm binaries will be found in the current terminal session, e.g. for bash:
    ```
    source ~/.bashrc
    ```

2. The script may cause issues if [Node Version Manager](https://github.com/creationix/nvm) is found installed. In this case it will exit and do nothing.

### License

MIT © [Adrian Sabau](https://github.com/baxy)