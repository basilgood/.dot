{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.git;

  difftools = {
    nvim = ''${pkgs.nvim}/bin/nvim -d "$LOCAL" "$REMOTE"'';
    vim = ''${pkgs.vim}/bin/vim -d "$LOCAL" "$REMOTE"'';
    kdiff3 = ''${pkgs.kdiff3}/bin/kdiff3 "$LOCAL" "$REMOTE"'';
  };

  mergetools = {
    nvim = ''
      ${pkgs.nvim}/bin/nvim -f -c "MergetoolStart" "$MERGED" "$BASE" "$LOCAL" "$REMOTE"'';
    vim = ''
      ${pkgs.vim}/bin/vim -f -c "MergetoolStart" "$MERGED" "$BASE" "$LOCAL" "$REMOTE"'';
    kdiff3 =
    ''${pkgs.kdiff3}/bin/kdiff3 "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'';
    v3 = ''
      ${pkgs.vim}/bin/vim -f -d  \"$LOCAL\" \"$MERGED\" \"$REMOTE\" \"+2wincmd w\"
      '';
    vimmerge = ''
      vimmerge \"$MERGED\"
    '';
    meld = ''
      ${pkgs.meld}/bin/meld --diff $BASE $LOCAL --diff $BASE $REMOTE --diff $LOCAL $BASE $REMOTE $MERGED
    '';
  };
in {
  options = {
    programs.git = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      lfsEnable = mkOption {
        type = types.bool;
        default = false;
      };

      name = mkOption {
        type = types.str;
        default = "";
      };

      email = mkOption {
        type = types.str;
        default = "";
      };

      editor = mkOption {
        type = types.str;
        default = "${pkgs.nvim}/bin/nvim";
      };

      pager = mkOption {
        type = types.str;
        default = "${pkgs.less}/bin/less";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };

      difftool = mkOption {
        type = types.enum [ "nvim" "vim" "kdiff3" ];
        default = "nvim";
      };

      mergetool = mkOption {
        type = types.enum [ "nvim" "vim" "kdiff3" "v3" "vimmerge" "meld" ];
        default = "nvim";
      };

      interface = mkOption {
        type = types.package;
        default = pkgs.gitAndTools.tig;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment = {
        systemPackages = with pkgs; [ git cfg.interface ];
        etc."gitconfig".text = ''
          [user]
            name = ${cfg.name}
            email = ${cfg.email}
          [core]
            editor = ${cfg.editor}
            pager = ${cfg.pager}
            excludesfile = $HOME/.gitignore
          [status]
            showuntrackedfiles = all
          [rerere]
            enabled = 1
            autoupdate = 1
          [color]
            diff = auto
            status = auto
            branch = auto
            ui = auto
          [color "diff"]
            meta = blue
            frag = black
            old = red
            new = green
          [color "status"]
            added = green
            changed = yellow
            untracked = cyan
          [color "branch"]
            current = yellow reverse
            local = yellow
            remote = green
          [alias]
            lg = log --oneline --graph --all
          ${cfg.extraConfig}
          [diff]
            prompt = false
            tool = diff_tool
          [difftool "diff_tool"]
            cmd = ${difftools.${cfg.difftool}}
          [merge]
            tool = diff_tool
            conflictstyle = diff3
          [mergetool "diff_tool"]
            prompt = false
            keepBackup = false
            cmd = ${mergetools.${cfg.mergetool}}
        '';
      };
    }

    (mkIf cfg.lfsEnable {
      environment.systemPackages = [ pkgs.git-lfs ];
      environment.etc."gitconfig".text = mkAfter ''
        [filter "lfs"]
          clean = git-lfs clean -- %f
          smudge = git-lfs smudge -- %f
          process = git-lfs filter-process
          required = true
      '';
    })
  ]);
}
