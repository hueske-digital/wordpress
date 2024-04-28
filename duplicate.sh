#!/bin/bash

echo "Gib den Namen des neuen Ordners (z. B. hueske) ein:"
read new_dir_name

echo "Gib die neue Domain (z. B. hueske.de) ein:"
read new_domain

current_dir="$(dirname "$(realpath "$0")")"

echo "Versuche, das Verzeichnis zu kopieren..."
cp -r "$current_dir" "$current_dir/../$new_dir_name" 2>/dev/null

if [[ $? -eq 0 ]]; then
    echo "Verzeichnis erfolgreich kopiert nach $current_dir/../$new_dir_name"
else
    echo "Fehler beim Kopieren des Verzeichnisses."
    exit 1
fi

source_file="$current_dir/../$new_dir_name/conf/caddy/Caddyfile"
destination_file="$current_dir/../caddy/hosts/external/$new_dir_name.conf"

if [[ -f "$source_file" ]]; then
    cp "$source_file" "$destination_file" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        echo "Caddyfile erfolgreich kopiert nach $destination_file"
        sed -i "s/example.com/$new_domain/g" "$destination_file"

        if [[ $? -eq 0 ]]; then
            echo "Domain erfolgreich ersetzt in $destination_file"
        else
            echo "Fehler beim Ersetzen der Domain."
            exit 1
        fi
    else
        echo "Fehler beim Kopieren des Caddyfile."
        exit 1
    fi
else
    echo "Das Quell-Caddyfile existiert nicht."
    exit 1
fi

echo "Vorgang erfolgreich abgeschlossen."
echo "Möchtest du 'docker compose up -d' im neuen Verzeichnis ausführen? (y/n)"
read answer
if [[ "$answer" == "y" ]]; then
    (cd "$current_dir/../$new_dir_name" && docker compose up -d)
    echo "Docker Compose wurde gestartet."
fi