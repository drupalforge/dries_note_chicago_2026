#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2025 DevPanel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation version 3 of the
# License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# For GNU Affero General Public License see <https://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------

#== Import database
if [ -z "$(drush status --field=db-status)" ]; then
  if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.gz" ]]; then
    echo  'Import mysql file ...'
    drush sqlq --file="$APP_ROOT/.devpanel/dumps/db.sql.gz" --file-delete
  fi
fi

if [[ -n "${DB_SYNC_VOL:-}" ]]; then
  echo 'Sync volume...'
  if [[ -n "$DRUPALFORGE_DEVCONTAINER" ]]; then
    # Preserve source permissions, but ensure rsync-created directories remain
    # user-writable so it can continue copying nested files on fresh volumes.
    sudo rsync -a --chmod=Du+w --ignore-existing --exclude .git --exclude .devpanel/dumps ./ ../build
  else
    sudo rsync -a --delete --ignore-existing --exclude .git --exclude .devpanel/dumps ./ ../build
  fi
fi

drush -n updb
echo
echo 'Run cron.'
drush cron
echo
echo 'Populate caches.'
drush cache:warm &> /dev/null || :
$APP_ROOT/.devpanel/warm
