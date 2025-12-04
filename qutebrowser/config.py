config.load_autoconfig(False)
# Genereal Settings
c.auto_save.session = True
c.content.autoplay  = True
# c.content.notifications = True
c.content.pdfjs = True
c.scrolling.smooth = True

# Appearance
c.tabs.show = "always"
# c.tabs.title.format = "{index}: {title}"
c.tabs.title.format_pinned = "{index}"
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.preferred_color_scheme = "dark"
c.fonts.default_family = ["Fira code", "Monospace"]

# Searching
c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "yt": "https://www.youtube.com/results?search_query={}",
    "yy": "https://www.yandex.com/search/?text={}"
}

c.url.start_pages = ["https://www.google.com"]
c.url.default_page = "https://www.google.com"

# Secury
c.content.cookies.accept = "no-3rdparty"
c.content.geolocation = False
c.content.headers.user_agent = "Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {qt_key}/{qt_version} {upstream_browser_key}/{upstream_browser_version} Safari/{webkit_version}"
c.content.javascript.enabled = True
c.content.local_storage = True
c.content.webgl = True
c.content.canvas_reading = True


# Advanced settings 
c.aliases = {
    "yt-dlp": "spawn yt-dlp {url}",
    "mpv": "spawn mpv {url}"
}
# c.qt.force_software_rendering = False


# Set config editor
# qutebrowser будет использовать системный EDITOR
import os
c.editor.command = [os.environ.get('EDITOR', 'vim'), '-f', '{file}']
