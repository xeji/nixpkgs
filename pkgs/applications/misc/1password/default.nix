{ stdenv, fetchzip, fetchpgpkey, verifySignatureHook }:

stdenv.mkDerivation rec {
  name = "1password-${version}";
  version = "0.4.1";
  src =
    if stdenv.system == "i686-linux" then
      fetchzip {
        url = "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_linux_386_v${version}.zip";
        sha256 = "1yzzh1f6hx7vwdgzp0znsjarjiw4xqmmrkc5xwywgjpg81qqpl8c";
        stripRoot = false;
      }
    else if stdenv.system == "x86_64-linux" then
      fetchzip {
        url = "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_linux_amd64_v${version}.zip";
        sha256 = "0dgj1zqmpdbnsz2v2j7nqm232cdgyp9wagc089dxi4hbzkmfcvzx";
        stripRoot = false;
      }
    else if stdenv.system == "x86_64-darwin" then
      fetchzip {
        url = "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_darwin_amd64_v${version}.zip";
        sha256 = "116bvyfg38npdhlzaxan5y47cbw7jvj94q5w6v71kxsjzxk9l44a";
        stripRoot = false;
      }
    else throw "Architecture not supported";

  nativeBuildInputs = [ verifySignatureHook ];

  signaturePublicKey = fetchpgpkey {
    url = https://keybase.io/1password/pgp_keys.asc;
    fingerprint = "3FEF9748469ADBE15DA7CA80AC2D62742012EA22";
    sha256 = "1v9gic59a3qim3fcffq77jrswycww4m1rd885lk5xgwr0qnqr019";
  };

  doCheck = true;
  checkPhase = ''
    verifySignature op.sig op
  '';

  installPhase = ''
    install -D op $out/bin/op
  '';
  postFixup = stdenv.lib.optionalString stdenv.isLinux ''
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/bin/op
  '';

  meta = with stdenv.lib; {
    description = "1Password command-line tool";
    homepage    = [
      "https://blog.agilebits.com/2017/09/06/announcing-the-1password-command-line-tool-public-beta/"
      "https://app-updates.agilebits.com/product_history/CLI"
    ];
    maintainers = with maintainers; [ joelburget ];
    license     = licenses.unfree;
    platforms   = [ "i686-linux" "x86_64-linux" "x86_64-darwin" ];
  };
}
