{
  pkgs ? use.pkgs,
}:
pkgs.mkShell {
  packages = with pkgs; [
    treefmt
    npins
    nixfmt-rfc-style
    shfmt
    taplo
    nodePackages.prettier
  ];
}
