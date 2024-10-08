#!/bin/bash

# GitHub Repo
repo_url="https://github.com/leinad13/homeserver.git"

# Clone Dir
clone_dir="homeserver"

cd ~

# Clone the Repo
git clone $repo_url $clone_dir
