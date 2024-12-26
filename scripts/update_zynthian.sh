#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Update Zynthian Software
# 
# + Update the Zynthian Software from repositories.
# + Install/update extra packages (recipes).
# + Reconfigure system.
# + Reboot when needed.
# 
# Copyright (C) 2015-2024 Fernando Moyano <jofemodo@zynthian.org>
#
#******************************************************************************
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# For a full copy of the GNU General Public License see the LICENSE.txt file.
# ****************************************************************************

#------------------------------------------------------------------------------
# Load Environment Variables
#------------------------------------------------------------------------------

source "$ZYNTHIAN_SYS_DIR/scripts/zynthian_envars_extended.sh"
source "$ZYNTHIAN_SYS_DIR/scripts/delayed_action_flags.sh"

#------------------------------------------------------------------------------
# Disable power save to run update at full speed
#------------------------------------------------------------------------------

powersave_control.sh off

#------------------------------------------------------------------------------
# Update from git - only if upstream has changed
#------------------------------------------------------------------------------
for repo_dir in 'zynthian-ui' 'zynthian-sys' 'zynthian-webconf' 'zynthian-data' 'zyncoder' ; do
  echo "Checking '$repo_dir' for updates..."
  git -C /zynthian/$repo_dir fetch --tags --all --prune --prune-tags --force
  BRANCH=`git -C /zynthian/$repo_dir symbolic-ref -q --short HEAD || git -C /zynthian/$repo_dir describe --tags --exact-match`
  LOCAL_HASH=`git -C /zynthian/$repo_dir rev-parse "$BRANCH"`
  REMOTE_HASH=`git -C /zynthian/$repo_dir ls-remote origin "$BRANCH" | awk '{ print $1 }'`
  if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo Updating $BRANCH
    git -C /zynthian/$repo_dir fetch -f origin --tags
    git -C /zynthian/$repo_dir checkout $BRANCH
  fi
done

#------------------------------------------------------------------------------
# Call update subscripts ...
#------------------------------------------------------------------------------

cd $ZYNTHIAN_SYS_DIR/scripts
./update_zynthian_sys.sh
./update_zynthian_recipes.sh
./update_zynthian_data.sh
./update_zynthian_sys.sh
./update_zynthian_code.sh

# Force restart of UI & webconf services
set_restart_ui_flag
set_restart_webconf_flag

run_flag_actions
sync

echo "Update Complete."

#------------------------------------------------------------------------------
