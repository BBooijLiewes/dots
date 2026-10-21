# neomutt.nix — PUBLIC repo, next to home.nix.
# Only UI/behaviour lives here. The account (host, address, login) is in
# ~/.config/nix-private/mail-account.nix; the password is in GNOME Keyring.
{ pkgs, ... }:

let
  # Neutral grey base like Zulip's dark theme and Chromium's GTK
  # (Adwaita-dark), with Neovim's Tokyo Night colours as the few accents.
  # Blue is only used for links. 256-colour palette, works over SSH too.
  #   greys    255 · 252 · 248 · 243 · 238 · 236 · 234
  #   accents  orange 215 · yellow 179 · purple 141 · red 210
  #            green 149 · teal 115 · cyan 117
  theme = pkgs.writeText "neomutt-theme.rc" ''
    # General UI
    color normal      default        default
    color error       color210       default
    color message     color149       default
    color status      color250       color236
    color indicator   bold color255  color238
    color tree        color141       default
    color markers     color243       default
    color tilde       color238       default
    color search      color234       color179
    color attachment  color215       default

    # Sidebar
    color sidebar_ordinary   color248       default
    color sidebar_divider    color238       default
    color sidebar_highlight  color255       color236
    color sidebar_indicator  bold color215  default
    color sidebar_new        bold color149  default
    color sidebar_flagged    color179       default

    # Message list: read mail is plain grey, unread is bold white with an
    # orange sender; colour otherwise only marks flagged/tagged/deleted
    color index         color248       default  "~A"
    color index_author  color248       default  "~A"
    color index_date    color243       default  "~A"
    color index_flags   color149       default  "~A"
    color index         bold color255  default  "~U"
    color index_author  bold color215  default  "~U"
    color index         color179       default  "~F"
    color index         color141       default  "~T"
    color index_author  color141       default  "~T"
    color index         color210       default  "~D"
    color index_author  color210       default  "~D"

    # Message headers
    color hdrdefault  color243       default
    color header      bold color215  default  "^From:"
    color header      bold color255  default  "^Subject:"

    # Message body: quote levels alternate warm and cool
    color quoted     color149  default
    color quoted1    color141  default
    color quoted2    color115  default
    color quoted3    color243  default
    color signature  color243  default
    color body  underline color117  default  "(https?|ftp)://[^[:space:]<>\"]+"
    color body  color115            default  "[[:alnum:]._%+-]+@[[:alnum:].-]+\\.[[:alpha:]]+"
  '';

  # Address completion (Tab in the To:/Cc: prompt) from your mail history
  addrQuery = pkgs.writeShellScript "neomutt-addr-query" ''
    echo "Searching your mail history..."
    ${pkgs.notmuch}/bin/notmuch address --output=sender --output=recipients \
      --deduplicate=address "from:$1* or to:$1*" 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -i -- "$1" \
      | ${pkgs.gnused}/bin/sed -E 's/^(.*) <(.*)>$/\2\t\1/'
  '';

  # Open an attachment or HTML mail in its default app. Copies the file
  # first, because neomutt deletes its temp file as soon as this returns.
  mailOpen = pkgs.writeShellScript "neomutt-open" ''
    ext="''${1##*.}"
    f=$(mktemp -p "''${XDG_RUNTIME_DIR:-/tmp}" --suffix=".$ext" mail-XXXXXX)
    cp -- "$1" "$f"
    ${pkgs.xdg-utils}/bin/xdg-open "$f" >/dev/null 2>&1 &
  '';
in
{
  programs.mbsync.enable = true; # IMAP <-> ~/Maildir
  programs.msmtp.enable = true;  # SMTP sending

  # Full-text search index over all mail (Ctrl-f in neomutt)
  programs.notmuch = {
    enable = true;
    new = {
      tags = [ "new" ]; # temporary marker for the notification hook below
      ignore = [ ".uidvalidity" "/[.]mbsyncstate/" ];
    };

    # Desktop notification (mako) for new unread mail in the Inbox.
    # "work" is the account name from mail-account.nix.
    hooks.postNew = ''
      n=$(${pkgs.notmuch}/bin/notmuch count 'tag:new and tag:unread and folder:"work/Inbox"')
      if [ "$n" -gt 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -a neomutt -i mail-unread "New mail" "$n unread in Inbox"
      fi
      ${pkgs.notmuch}/bin/notmuch tag -new -- tag:new
    '';
  };

  # Pull mail every 5 minutes, then update the search index
  services.mbsync = {
    enable = true;
    frequency = "*:0/5";
    postExec = "${pkgs.notmuch}/bin/notmuch new --quiet";
  };

  # auto receive mails
  services.imapnotify.enable = true;

  programs.neomutt = {
    enable = true;

    # neomutt's bundled vim-keys.rc: gg/G, dd, dt/dT, Ctrl-d/u, za/zA, gt/gT, N
    vimKeys = true;

    # Newest at the top, flat list
    sort = "reverse-date";

    sidebar = {
      enable = true;
      width = 26;
      shortPath = true;
    };

    # Keep sidebar unread counts fresh
    checkStatsInterval = 60;

    settings = {
      mark_old = "no";
      maildir_header_cache_verify = "no"; # don't re-check every file when opening a folder
      text_flowed = "yes";           # replies re-wrap nicely on phones and other clients
      pager_index_lines = "10";
      pager_context = "3";
      pager_stop = "yes";            # don't jump to the next mail at the end of one
      wrap = "100";                  # keep long lines readable on a wide screen
      menu_scroll = "yes";
      sleep_time = "0";              # no pause when switching folders
      markers = "no";                # no '+' at the start of wrapped lines
      wait_key = "no";
      fast_reply = "yes";
      include = "yes";
      auto_tag = "yes";              # commands apply to all tagged mails
      confirm_append = "no";         # no prompt when moving mail
      send_charset = "us-ascii:utf-8";
      abort_noattach = "ask-yes";    # warn when you mention an attachment but forgot it
      mailcap_path = "~/.config/neomutt/mailcap";
    };

    binds = [
      # h/l to go in and out, like a file tree
      { map = [ "index" ];          key = "l"; action = "display-message"; }
      { map = [ "pager" "attach" ]; key = "h"; action = "exit"; }
      { map = [ "pager" ];          key = "l"; action = "view-attachments"; }
      { map = [ "attach" ];         key = "l"; action = "view-mailcap"; }
      { map = [ "browser" ];        key = "h"; action = "goto-parent"; }
      { map = [ "browser" ];        key = "l"; action = "select-entry"; }

      # Sidebar
      { map = [ "index" "pager" ]; key = "\\Ck"; action = "sidebar-prev"; }
      { map = [ "index" "pager" ]; key = "\\Cj"; action = "sidebar-next"; }
      { map = [ "index" "pager" ]; key = "\\Co"; action = "sidebar-open"; }
      { map = [ "index" "pager" ]; key = "B";    action = "sidebar-toggle-visible"; }

      # vim-keys turns `g` into a prefix, so group reply moves to R
      { map = [ "index" "pager" ]; key = "R"; action = "group-reply"; }

      # Show only matching mails (l is used for opening mail)
      { map = [ "index" ]; key = "L"; action = "limit"; }

      # `M` becomes a prefix for the move macros below
      { map = [ "index" "pager" ]; key = "M"; action = "noop"; }

      # Search all mail with notmuch (replaces vim-keys' Ctrl-f page-down;
      # Ctrl-d / Ctrl-u still scroll)
      { map = [ "index" "pager" ]; key = "\\Cf"; action = "vfolder-from-query"; }

      # Tab completes addresses from your mail history
      { map = [ "editor" ]; key = "<Tab>"; action = "complete-query"; }
    ];

    macros = [
      # Folder jumps
      { map = [ "index" "pager" ]; key = "gi"; action = "<change-folder>!<enter>"; }
      { map = [ "index" "pager" ]; key = "gs"; action = "<change-folder>=Sent<enter>"; }
      { map = [ "index" "pager" ]; key = "gd"; action = "<change-folder>=Drafts<enter>"; }

      # Only flagged mail / all mail again
      { map = [ "index" ]; key = "gf"; action = "<limit>~F<enter>"; }
      { map = [ "index" ]; key = "ga"; action = "<limit>all<enter>"; }

      # Move mail (or all tagged mail) to a folder
      { map = [ "index" "pager" ]; key = "Mi"; action = "<save-message>!<enter>"; }
      { map = [ "index" "pager" ]; key = "Mj"; action = "<save-message>=Junk<enter>"; }
      { map = [ "index" "pager" ]; key = "Mt"; action = "<save-message>=Trash<enter>"; }

      # Sync now via the same systemd service as the timer, so the two never
      # overlap and the search index is updated too
      { map = [ "index" ]; key = "o"; action = "<shell-escape>systemctl --user start mbsync.service<enter>"; }

      # Pick a link from the current mail and open it in the browser
      { map = [ "index" "pager" ]; key = "U"; action = "<pipe-message>${pkgs.urlscan}/bin/urlscan --dedupe<enter>"; }
    ];

    extraConfig = ''
      source ${theme}

      # Message list: flags, smart 24h date (time today, day+month this year,
      # full date when older), sender, subject, attachment count on the right
      set index_format = " %Z  %<[y?%<[d?%[%H:%M   ]&%[%d %b  ]>&%[%d-%m-%y]>  %-22.22F  %s%* %<X?[%X]>"
      set date_format = "%a %d %b %Y %H:%M"

      # What counts as an attachment for the [N] counter
      attachments +A */.*
      attachments -A text/x-vcard application/pgp.* application/x-pkcs7-.*
      attachments +I text/plain

      # Only show the headers that matter, in a fixed order
      ignore *
      unignore from: to: cc: date: subject:
      hdr_order from: to: cc: date: subject:

      set forward_format = "Fwd: %s"
      set abort_noattach_regex = "\\<(attach|attached|attachments?|bijlage|bijlagen|bijgevoegd)\\>"

      # neomutt quotes %s itself, so no quotes around it here
      set query_command = "${addrQuery} %s"

      # Correct MIME types for files you attach (e.g. PDFs as application/pdf)
      set mime_type_query_command = "${pkgs.file}/bin/file --mime-type -b %s"

      # Prefer plain text, render HTML-only mail inline; show meeting
      # invites as a readable summary instead of raw calendar code
      unalternative_order *
      alternative_order text/calendar text/plain text/enriched text/html
      auto_view text/html text/calendar application/ics
    '';
  };

  # First matching entry is used when you open an attachment (l in the
  # attachment list); the copiousoutput entry renders HTML inside neomutt.
  xdg.configFile."neomutt/mailcap".text = ''
    text/html; ${mailOpen} %s; nametemplate=%s.html
    text/html; ${pkgs.w3m}/bin/w3m -I %{charset} -T text/html -dump -cols 100 -o display_link_number=1; copiousoutput
    text/calendar; ${pkgs.mutt-ics}/bin/mutt-ics; copiousoutput
    application/ics; ${pkgs.mutt-ics}/bin/mutt-ics; copiousoutput
    application/pdf; ${mailOpen} %s
    image/*; ${mailOpen} %s
  '';
}
