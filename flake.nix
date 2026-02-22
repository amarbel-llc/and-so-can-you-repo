{
  description = "Interactive scaffold for new nix-flake-backed repos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/6d41bc27aaf7b6a3ba6b169db3bd5d6159cfaa47";
    nixpkgs-master.url = "github:NixOS/nixpkgs/5b7e21f22978c4b740b3907f3251b470f466a9a2";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";
    shell.url = "github:amarbel-llc/eng?dir=devenvs/shell";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      utils,
      shell,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        name = "and-so-can-you-repo";
        script = (
          pkgs.writeScriptBin name (builtins.readFile ./bin/and-so-can-you-repo.bash)
        ).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
        buildInputs = with pkgs; [
          gum
          gh
        ];
      in
      {
        packages.default = pkgs.symlinkJoin {
          inherit name;
          paths = [ script ] ++ buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            just
            gum
            gh
          ];

          inputsFrom = [
            shell.devShells.${system}.default
          ];

          shellHook = ''
            echo "${name} - dev environment"
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${name}";
        };
      }
    );
}
