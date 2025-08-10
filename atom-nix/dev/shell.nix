{
  pkgs ? mod.pkgs,
}:
pkgs.mkShell {
  packages = with pkgs; [
    treefmt
    nixfmt-rfc-style
    shfmt
    taplo
    nodePackages.prettier
  ];
}
