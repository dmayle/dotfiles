{ pkgs, lib, inputs, ... }:

let
  patchGoogleChrome = true;
in
{
  config = {
    nixpkgs.overlays = [
      (final: prev: (
        # {
	#   xwayland = prev.xwayland.overrideAttrs (old: rec {
	#     version = "21.1.3";
	#     src = prev.fetchFromGitLab {
	#       domain = "gitlab.freedesktop.org";
	#       owner = "xorg";
	#       repo = "xserver";
	#       rev = "21e3dc3b5a576d38b549716bda0a6b34612e1f1f";
	#       sha256 = "sha256-i2jQY1I9JupbzqSn1VA5JDPi01nVA6m8FwVQ3ezIbnQ=";
	#     };
	#   });
	# } //

	(lib.optionalAttrs patchGoogleChrome {
	  google-chrome = (let
	    c = prev.google-chrome;
	    in prev.runCommandNoCC "wrap-chrome"
	      { buildInputs = with pkgs; [ makeWrapper ]; }
	      ''
	        makeWrapper ${c}/bin/google-chrome-stable $out/bin/google-chrome \
		  --add-flags "--enable-features=UseOzonePlatform" \
		  --add-flags "--use-gl=egl" \
		  --add-flags "--ignore-gpu-blocklist" \
		  --add-flags "--enable-gpu-rasterization" \
		  --add-flags "--enable-zero-copy" \
		  --add-flags "--enable-features=VaapiVideoDecoder" \
		  --add-flags "--ozone-platform=wayland"

		ln -sf ${c}/share $out/share
	      ''
	  );
	})
      ))
    ];
  };
}
