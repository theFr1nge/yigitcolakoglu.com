#!/bin/bash


info(){
  printf "[\e[32mINFO\e[0m]:%s\n" "$1"
}


prompt(){
  printf "[\e[35mPROMPT\e[0m]: %s" "$1"
  read -r ans
  printf "%s" "$ans"
}

error(){
  printf "[\e[31mERROR\e[0m]:%s\n" "$1"
}

while 1; do
    info "Please select the image file: "

    loc=$(find "$HOME" -name "*.jpg" | fzf --height=15)

    if [ -z "$loc" ]; then
        info "Continuing with the installation..."
        exit
    fi

    jsteg reveal "$loc" 2> /dev/null > /tmp/out.zip.gpg

    if [ ! -f "/tmp/out.zip.gpg" ]; then
        retry=$(prompt "No file found in $loc, would you like to try again(Y/n)?")
        if [ "$retry" = "n" ]; then
            exit
        else
            continue
        fi
    fi
    break
done

while 1; do
    info "Please enter your passphrase: "
    gpg -d /tmp/out.zip.gpg > /tmp/out.zip

    if [ ! $? = 0 ]; then
            retry=$(prompt "You might have entered the wrong password, would you like to try again(Y/n)?")
            if [ "$retry" = "n" ]; then
                exit
            else
                continue
            fi
    fi
    break
done

unzip /tmp/out.zip -d /tmp/keys

gpg --import /tmp/keys/gpg.key

mkdir -p ~/.ssh

chmod 700 ~/.ssh

cp /tmp/keys/id_* ~/.ssh



