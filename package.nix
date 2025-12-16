{ stdenv, lib, fetchurl, autoPatchelfHook, version, url, nixHash }:

stdenv.mkDerivation {
  pname = "proton-pass-cli";
  inherit version;

  src = fetchurl {
    inherit url;
    sha256 = nixHash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optional stdenv.isLinux autoPatchelfHook;

  buildInputs = lib.optional stdenv.isLinux stdenv.cc.cc.lib;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/pass-cli
    chmod +x $out/bin/pass-cli
    runHook postInstall
  '';

  meta = with lib; {
    description = "Proton Pass CLI - command line interface for Proton Pass";
    homepage = "https://protonpass.github.io/pass-cli/";
    license = licenses.unfree;
    mainProgram = "pass-cli";
    platforms = [ stdenv.hostPlatform.system ];
  };
}
