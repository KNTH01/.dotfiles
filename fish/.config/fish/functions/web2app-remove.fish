function web2app-remove
    if test (count $argv) -ne 1
        echo "Usage: web2app-remove <AppName>"
        return 1
    end

    set APP_NAME $argv[1]
    set ICON_DIR "$HOME/.local/share/applications/icons"
    set DESKTOP_FILE "$HOME/.local/share/applications/$APP_NAME.desktop"
    set ICON_PATH "$ICON_DIR/$APP_NAME.png"

    rm "$DESKTOP_FILE"
    rm "$ICON_PATH"
end