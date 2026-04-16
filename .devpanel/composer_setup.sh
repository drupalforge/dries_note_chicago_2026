#!/usr/bin/env bash
# This file is an example for a template that wraps a Composer project. It
# pulls composer.json from the Drupal recommended project and customizes it.
# You do not need this file if your template provides its own composer.json.

set -eu -o pipefail
cd $APP_ROOT

# Create required composer.json and composer.lock files.
git clone --depth 1 --quiet https://github.com/fosterinteractive/c2026.git
rm -rf c2026/LICENSE.txt
cp -rn c2026/* ./
cp -n c2026/.ddev/.env.template .ddev/
rm -rf c2026

# Allow insecure packages.
composer config audit.ignore SA-CONTRIB-2026-006 SA-CONTRIB-2026-017

# Scaffold settings.php.
composer config -jm extra.drupal-scaffold.file-mapping '{
    "[web-root]/robots.txt": false,
    "[web-root]/sites/default/settings.php": {
        "path": "web/core/assets/scaffold/files/default.settings.php",
        "overwrite": false
    },
    "[web-root]/base-path-rewrite.js": ".devpanel/base-path-rewrite.js"
}'
composer config scripts.post-drupal-scaffold-cmd \
    'cd web/sites/default && test -z "$(grep '\''include \$devpanel_settings;'\'' settings.php)" && patch -Np1 -r /dev/null < $APP_ROOT/.devpanel/drupal-settings.patch || :'
