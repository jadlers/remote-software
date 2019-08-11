function checkForUpdate() {
    var response = mainLauncher.launch("curl -L https://api.github.com/repos/martonborzak/yio-remote/releases/latest");
    var obj = JSON.parse(response);
    if (obj.tag_name >= _current_version + 0.1) {
        console.debug("New version is available")
        console.debug(obj.assets[0].browser_download_url);
        _new_version = obj.tag_name;
        updateURL = obj.assets[0].browser_download_url;
        updateAvailable = true;
    } else {
        console.debug("No update");
        updateAvailable = false;
    }
}
