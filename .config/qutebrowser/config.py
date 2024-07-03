config.load_autoconfig(False)
c.statusbar.show = 'in-mode'
c.url.start_pages = ['gitlab.codeyellow.nl']
c.editor.command = ['/home/bob/.local/kitty.app/bin/kitty', 'nvim', '-f', '{file}', '-c', 'normal {line}G{column0}l']




config.bind(',M', 'hint links spawn mpv {url}')
config.bind(',P', 'spawn --userscript qute-lastpass')

config.bind(',cp', 'spawn --userscript ~/.config/qutebrowser/userscripts/qute-phabticket')

config.bind(',pu', 'spawn --userscript qute-lastpass --username-only')
config.bind(',pu', 'spawn --userscript qute-lastpass --username-only')
config.bind(',do', 'devtools')
config.bind(',df', 'devtools-focus')

config.set("colors.webpage.darkmode.enabled", True)
config.set('colors.webpage.darkmode.policy.images', 'never')





c.url.searchengines = {
    'DEFAULT':  'https://google.com/search?hl=en&q={}',
    '!gh':      'https://github.com/search?o=desc&q={}&s=stars',
    '!gist':    'https://gist.github.com/search?q={}',
    '!gi':      'https://www.google.com/search?tbm=isch&q={}&tbs=imgo:1',
    '!gm':       'https://www.google.com/maps/search/{}',
    '!w':       'https://en.wikipedia.org/wiki/{}',
    '!yt':      'https://www.youtube.com/results?search_query={}',
    '!gl':      'https://gitlab.codeyellow.nl/search?search={}',
    '!ph':      'https://phabricator.codeyellow.nl/search/?query={}',

}
