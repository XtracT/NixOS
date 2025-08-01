{
  self,
  pkgs,
  terminalFileManager,
  ...
}: {
  home-manager.sharedModules = [
    (_: {
      xdg.configFile."zsh/.p10k.zsh".source = ./.p10k.zsh;
      xdg.configFile."zsh/templates" = {
        source = ./templates;
        recursive = true;
      };
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        history.size = 100000;
        history.path = "\${XDG_DATA_HOME}/zsh/history";
        dotDir = ".config/zsh";
        # plugins = [
        #   {
        #     name = "powerlevel10k";
        #     file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        #     src = pkgs.zsh-powerlevel10k;
        #   }
        # ];
        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "gitignore"
            "z"
          ];
        };
        initContent = ''
          # Powerlevel10k Zsh theme
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh

          # Direnv hook
          eval "$(direnv hook zsh)"

          # Key Bindings
          # bindkey -s ^t "tmux-sessionizer\n"
          # bindkey '^f' "cd $(${pkgs.fd}/bin/fd . /mnt/work /mnt/work/Projects/ /run/current-system ~/ --max-depth 1 | fzf)\n"
          bindkey '^l' "${terminalFileManager}\r"
          bindkey '^a' beginning-of-line
          bindkey '^e' end-of-line

          # options
          unsetopt menu_complete
          unsetopt flowcontrol

          setopt prompt_subst
          setopt always_to_end
          setopt append_history
          setopt auto_menu
          setopt complete_in_word
          setopt extended_history
          setopt hist_expire_dups_first
          setopt hist_ignore_dups
          setopt hist_ignore_space
          setopt hist_verify
          setopt inc_append_history
          setopt share_history

          function lf {
              tmp="$(mktemp)"
              # `command` is needed in case `lfcd` is aliased to `lf`
              command lf -last-dir-path="$tmp" "$@"
              if [ -f "$tmp" ]; then
                  dir="$(cat "$tmp")"
                  rm -f "$tmp"
                  if [ -d "$dir" ]; then
                      if [ "$dir" != "$(pwd)" ]; then
                          cd "$dir"
                      fi
                  fi
              fi
          }
          function ex {
           if [ -z "$1" ]; then
              # display usage if no parameters given
              echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
              echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
           else
              for n in "$@"
              do
                if [ -f "$n" ] ; then
                    case "''${n%,}" in
                      *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                      ${pkgs.gnutar}/bin/tar xvf "$n"       ;;
                      *.lzma)      unlzma ./"$n"      ;;
                      *.bz2)       bunzip2 ./"$n"     ;;
                      *.cbr|*.rar)       unrar x -ad ./"$n" ;;
                      *.gz)        gunzip ./"$n"      ;;
                      *.cbz|*.epub|*.zip)       unzip ./"$n"       ;;
                      *.z)         uncompress ./"$n"  ;;
                      *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                      ${pkgs.p7zip}/bin/7z x ./"$n"        ;;
                      *.xz)        unxz ./"$n"        ;;
                      *.exe)       cabextract ./"$n"  ;;
                      *.cpio)      cpio -id < ./"$n"  ;;
                      *.cba|*.ace)      unace x ./"$n"      ;;
                      *)
                      echo "Unsupported format"
                      return 1
                      ;;
                    esac
                else
                    echo "'$n' - file does not exist"
                    return 1
                fi
              done
           fi
          }

          function fnew {
            if [ -d "$1" ]; then
              echo "Directory \"$1\" already exists!"
              return 1
            fi
            nix flake new $1 --template ${self}/dev-shells#$2
            cd $1
            direnv allow
          }

          function finit {
            nix flake init --template ${self}/dev-shells#$1
            direnv allow
          }

          function cgen {
            if [ -d "$1" ]; then
              echo "Directory \"$1\" already exists!"
              return 1
            fi
            nix flake new $1 --template ${self}/dev-shells#c-cpp
            cd $1
            cat ~/.config/zsh/templates/ListTemplate.txt >> CMakeLists.txt
            mkdir src
            mkdir include
            cat ~/.config/zsh/templates/HelloWorldTemplate.txt >> src/main.cpp
            direnv allow
          }

          function crun {
            #VAR=''${1:-.}
            mkdir build 2> /dev/null
            cmake -B build
            cmake --build build
            build/main
          }

          function cbuild {
            mkdir build 2> /dev/null
            cmake -B build
            cmake --build build
          }

         if [[ "$TERM" == "xterm-kitty" ]]; then
           alias ssh="TERM=xterm-256color ssh"
         fi
        '';
        envExtra = ''
          # Defaults
          export XMONAD_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/xmonad" # xmonad.hs is expected to stay here
          export XMONAD_DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/xmonad"
          export XMONAD_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/xmonad"

          export FZF_DEFAULT_OPTS=" \
          --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
          --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
          --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
        '';
        shellGlobalAliases = {
          UUID = "$(uuidgen | tr -d \\n)";
          G = "| grep";
        };
        shellAliases = {
          cls = "clear";
          tml = "tmux list-sessions";
          attach = "tmux attach";
          att = "tmux attach";
          l = "${pkgs.eza}/bin/eza -lh  --icons=auto"; # long list
          ls = "${pkgs.eza}/bin/eza -1   --icons=auto"; # short list
          ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first"; # long list all
          ld = "${pkgs.eza}/bin/eza -lhD --icons=auto"; # long list dirs
          tree = "${pkgs.eza}/bin/eza --icons=auto --tree"; # dir tree
          vc = "code --disable-gpu"; # gui code editor
          nv = "nvim";
          nf = "${pkgs.microfetch}/bin/microfetch";
          cp = "cp -iv";
          mv = "mv -iv";
          rm = "rm -vI";
          bc = "bc -ql";
          mkd = "mkdir -pv";
          tp = "${pkgs.trash-cli}/bin/trash-put";
          tpr = "${pkgs.trash-cli}/bin/trash-restore";
          grep = "grep --color=always";
          pokemon = "pokego --random 1-8 --no-title";

          # Nixos
          list-gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system/";
          find-store-path = ''function { nix-shell -p $1 --command "nix eval -f \"<nixpkgs>\" --raw $1" }'';
          update-input = "nix flake update $@";
          rebuild = "${../../../desktop/hyprland/scripts/rebuild.sh}";
          sysup = "sudo nixos-rebuild switch --flake ~/NixOS#Default --upgrade-all --show-trace";

          # Directory Shortcuts.
          dots = "cd ~/NixOS/";
          games = "cd /mnt/games/";
          work = "cd /mnt/work/";
          media = "cd /mnt/work/media/";
          projects = "cd /mnt/work/Projects/";
          proj = "cd /mnt/work/Projects/";
          dev = "cd /mnt/work/Projects/";
          # dev = "cd /mnt/work/dev/";
          # nixdir = "cd /mnt/work/dev/nix/";
          # cppdir = "cd /mnt/work/dev/C++/";
          # zigdir = "cd /mnt/work/dev/Zig/";
          # csdir = "cd /mnt/work/dev/C#/";
          # rustdir = "cd /mnt/work/dev/Rust/";
          # pydir = "cd /mnt/work/dev/Python/";
          # javadir = "cd /mnt/work/dev/Java/";
          # luadir = "cd /mnt/work/dev/lua/";
          # webdir = "cd /mnt/work/dev/Website/";
        };
      };
    })
  ];
}
