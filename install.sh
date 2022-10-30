#!/bin/sh

set -e

echo "Beginning installation of spicetify-fluent"
echo "https://github.com/williamckha/spicetify-fluent"

# Give time for user to cancel via CTRL+C
sleep 3s

# Check if ~\.spicetify-cli\Themes\Fluent directory exists
spicePath=$(dirname "$(spicetify -c)")
themePath="$spicePath/Themes/Fluent"
if [ ! -d $themePath ]; then
    echo "Creating Fluent theme folder..."
    mkdir -p $themePath
else
    # Remove pre-existing files, only keep the newest files
    rm -rfv "$themePath/*"
fi

# Download latest master
zipUri="https://github.com/williamckha/spicetify-fluent/archive/refs/heads/master.zip"
zipSavePath="$themePath/fluent-master.zip"
echo "Downloading spicetify-fluent latest master..."
curl --fail --location --progress-bar --output "$zipSavePath" "$zipUri" 


# Extract theme from .zip file
echo "Extracting..."
unzip -d "$themePath" -o "$zipSavePath"
mv $themePath/spicetify-fluent-master/* $themePath
rm -rf $themePath/spicetify-fluent-master

# Delete .zip file
echo "Deleting zip file..."
rm "$zipSavePath"

# Change Directory to the Theme Folder
cd $themePath

# Copy the fluent.js to the Extensions folder
mkdir -p ../../Extensions
cp fluent.js ../../Extensions/.
echo "+ Installed fluent.js extension"

# Apply the theme with spicetify config calls
spicetify config extensions fluent.js
spicetify config current_theme Fluent
spicetify config color_scheme dark
spicetify config inject_css 1 replace_colors 1 overwrite_assets 1
echo "+ Configured Fluent theme"

# Patch the xpui.js for sidebar fixes
# credit: https://github.com/JulienMaille/dribbblish-dynamic-theme/blob/main/install.sh
PATCH='[Patch]
xpui.js_find_8008 = ,(\\w+=)32,
xpui.js_repl_8008 = ,\${1}58,'
if cat config-xpui.ini | grep -o '\[Patch\]'; then
    perl -i -0777 -pe "s/\[Patch\].*?($|(\r*\n){2})/$PATCH\n\n/s" config-xpui.ini
else
    echo -e "\n$PATCH" >> config-xpui.ini
fi
echo "+ Patched xpui.js for Sidebar fixes"

spicetify apply
echo "+ Applied Theme"
