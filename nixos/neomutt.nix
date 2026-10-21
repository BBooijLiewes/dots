# neomutt.nix — PUBLIC repo, next to home.nix.
# Only UI/behaviour lives here. The account (host, address, login) is in
# mail-account.nix in a private repo; the password is in GNOME Keyring.
{ pkgs, ... }:

let
  # mutt-wizard's colours and message-list layout, taken from the packaged
  # config so they match upstream. Its keybindings/macros are left out.
  mwLook = pkgs.runCommand "mutt-wizard-look.muttrc" { } ''
    grep -E '^[[:space:]]*(color|mono)[[:space:]]|^set (index_format|date_format)[[:space:]=]' \
      ${pkgs.mutt-wizard}/share/mutt-wizard/mutt-wizard.muttrc > $out
  '';
in
{
  programs.mbsync.enable = true; # IMAP <-> ~/Maildir
  programs.msmtp.enable = true;  # SMTP sending

  # Pull mail every 5 minutes (systemd user timer)
  services.mbsync = {
    enable = true;
    frequency = "*:0/5";
  };

  programs.neomutt = {
    enable = true;

    # neomutt's bundled vim-keys.rc: gg/G, dd, dt/dT, Ctrl-d/u, za/zA, gt/gT, N
    vimKeys = true;

    sort = "reverse-date";          # ← new line

    sidebar = {
      enable = true;
      width = 26;
      shortPath = true;
    };

    # Keep sidebar unread counts fresh
    checkStatsInterval = 60;

    settings = {
      mark_old = "no";
      pager_index_lines = "10";
      pager_context = "3";
      menu_scroll = "yes";
      wait_key = "no";
      fast_reply = "yes";
      include = "yes";
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
    ];

    macros = [
      # Folder jumps; match =Sent / =Drafts to the names `mbsync -l work` shows
      { map = [ "index" "pager" ]; key = "gi"; action = "<change-folder>!<enter>"; }
      { map = [ "index" "pager" ]; key = "gs"; action = "<change-folder>=Sent<enter>"; }
      { map = [ "index" "pager" ]; key = "gd"; action = "<change-folder>=Drafts<enter>"; }

      # Sync now instead of waiting for the timer
      { map = [ "index" ]; key = "o"; action = "<shell-escape>mbsync -a<enter>"; }
    ];

    extraConfig = ''
      source ${mwLook}
      
      set date_format = "%d-%m-%y %H:%M"

      # Prefer plain text, render HTML-only mail inline
      alternative_order text/plain text/enriched text/html
      auto_view text/html
    '';
  };

  xdg.configFile."neomutt/mailcap".text = ''
    text/html; ${pkgs.w3m}/bin/w3m -I %{charset} -T text/html -dump; copiousoutput
  '';
}
