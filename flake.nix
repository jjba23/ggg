# ggg: guile glyph generator

# Copyright © Josep Bigorra <jjbigorra@gmail.com>

# ggg is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# ggg is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with ggg.  If not, see <https://www.gnu.org/licenses/>.

{
  description = "GGG: Guile Glyph Generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./default.nix { };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
          buildInputs = [
            pkgs.watchexec
            pkgs.guile-ares-rs
          ];
        };
      });
}
