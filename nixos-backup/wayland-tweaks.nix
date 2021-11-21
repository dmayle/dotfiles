{ pkgs, lib, inputs, ... }:

let
  patchGoogleChrome = true;
in
{
  config = {
    nixpkgs.overlays = [
      (final: prev: (
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
