{
  lib,
  ...
}:

rec {
  mapAttrsMaybe =
    f: attrs:
    lib.pipe attrs [
      (lib.mapAttrsToList f)
      (builtins.filter (x: x != null))
      builtins.listToAttrs
    ];
  /**
    Gets the toplevel nix files of a directory.

    This is simmilar to a glob-pattern like `*.nix | *\/default.nix`.

    # Arguments

    dir
    : Path of the directory to scan for nix files.
  */
  readDirNixFiles = mapDirNixFiles lib.id;

  zipDirsNixFilesWith = f: dirs: lib.zipAttrsWith f (builtins.map readDirNixFiles dirs);

  zipDirsNixFiles = zipDirsNixFilesWith (name: values: values);

  mapDirNixFiles =
    f: dir:
    if builtins.pathExists dir then
      lib.pipe dir [
        builtins.readDir
        (mapAttrsMaybe (
          filename: type:
          if type == "regular" && lib.hasSuffix ".nix" filename then
            let
              name = lib.removeSuffix ".nix" filename;
            in
            lib.nameValuePair name (f "${dir}/${filename}")
          else if type == "directory" && builtins.pathExists "${dir}/${filename}/default.nix" then
            lib.nameValuePair filename (f "${dir}/${filename}")
          else
            null
        ))
      ]
    else
      { };

}
