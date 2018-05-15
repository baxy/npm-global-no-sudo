#!/bin/sh

echo "This script fixes the issues encountered when you are required to use 'sudo' to install npm global packages."
echo "The fix consists in creating a new local directory for global packages (default: ~/.npm-packages), configure node to use it and fix permissions."
echo "Existing global packages will be backed up and reinstalled after the fix.\n"

if [ -f $NVM_DIR/nvm.sh ]; then
    echo "NVM was found. Exiting because it may cause issues!"
    exit
fi

set_npm_directory() {
    DEFAULT_NPM_DIR="${HOME}/.npm-packages"
    NPM_DIR=""

    echo " "
    read -p "Choose directory (default: ${DEFAULT_NPM_DIR}): " NPM_DIR

    if [ -z ${NPM_DIR} ]; then
        NPM_DIR=${DEFAULT_NPM_DIR}
    fi

    if [ ! -d ${NPM_DIR} ]; then
        read -p "${NPM_DIR} directory does not exist. Do you wish to create it? [y/n] " answer
        case $answer in
            [Yy]* )
                mkdir -p ${NPM_DIR}
                ;;
            [Nn]* )
                exit
                ;;
            * )
                echo "Invalid answer"
                ;;
        esac
    fi
}

ENV_VARS='
export NPM_PACKAGES="%s"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
'

do_fix() {
    echo "\nSaving the existing list of global packages..."
    EXISTING_PACKAGES="${HOME}/npm-global-packages-backup.tmp"
    npm -g list --depth=0 --parseable --long | cut -d: -f2 | grep -v '^npm@\|^$' > $EXISTING_PACKAGES

    if [ -s $EXISTING_PACKAGES ]; then
        echo "\nUninstalling existing global packages, your sudo password might be required..."
        cat $EXISTING_PACKAGES | sed -e 's/@.*//' | xargs sudo npm -g uninstall
    else
        echo "\nNo global packages found, nothing to uninstall."
    fi

    set_npm_directory
    echo "\nFixing permissions, your sudo password might be required..."
    npm config set prefix $NPM_DIR
    sudo chown -R `whoami` $NPM_DIR

    if [ -s $EXISTING_PACKAGES ]; then
        echo "\nInstalling existing global packages..."
        cat $EXISTING_PACKAGES | sed -e 's/@.*//' | xargs npm -g install

        rm $EXISTING_PACKAGES

        echo "\nFinished installing.\n\nCurrent global packages list:\n"
        npm -g list -depth=0
    else
        echo "\nNo global packages found, nothing to install.\n"
    fi

    if [ -f "${HOME}/.bashrc" ];    then
        printf "${ENV_VARS}" ${NPM_DIR} >> ~/.bashrc
        echo "Don't forget to run 'source ~/.bashrc'\n"
    fi

    if [ -f "${HOME}/.zshrc" ]; then
        printf "${ENV_VARS}" ${NPM_DIR} >> ~/.zshrc
        echo "Don't forget to run 'source ~/.zshrc'\n"
    fi
}

read -p "Do you wish to continue? [y/n] " answer
case $answer in
    [Yy]* )
        do_fix
        ;;
    [Nn]* )
        exit
        ;;
    * )
        echo "Invalid answer"
        ;;
esac
