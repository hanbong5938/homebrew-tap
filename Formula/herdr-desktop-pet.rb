class HerdrDesktopPet < Formula
  desc "Native desktop companion for Herdr and Tern with agent messaging"
  homepage "https://github.com/hanbong5938/herdr-desktop-pet"
  url "https://github.com/hanbong5938/herdr-desktop-pet/releases/download/v0.3.6/HerdrDesktopPet-v0.3.6-macos-arm64.tar.gz"
  sha256 "5d40f6ada23f7d91d967a98331b28ea767202f5d01b7cd7732b2d9e543fdaafa"
  # Software is MIT; bundled artwork is not MIT-licensed.
  license :cannot_represent

  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    # Homebrew stages the single top-level `HerdrDesktopPet.app` directory by
    # changing into it, so the working directory holds `Contents`.
    (libexec/"HerdrDesktopPet.app").install "Contents"
    # Wrapper script, not a symlink: the binary resolves its resources relative
    # to its own path inside the app bundle.
    bin.write_exec_script libexec/"HerdrDesktopPet.app/Contents/MacOS/herdr-desktop-pet"
  end

  post_install_steps do
    # Keg relocation may rewrite the dylib install id and re-sign it on its own,
    # breaking the bundle's ad-hoc seal. Re-sign inner-to-outer like the packager.
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPet.app/Contents/Frameworks/libherdr_rig.dylib"],
        writable_paths: ["{{libexec}}/HerdrDesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--preserve-metadata=entitlements", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPet.app/Contents/MacOS/rig-decode-worker"],
        writable_paths: ["{{libexec}}/HerdrDesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPet.app/Contents/MacOS/herdr-update-coordinator"],
        writable_paths: ["{{libexec}}/HerdrDesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPet.app/Contents/MacOS/herdr-desktop-pet"],
        writable_paths: ["{{libexec}}/HerdrDesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-", "{{libexec}}/HerdrDesktopPet.app"],
        writable_paths: ["{{libexec}}/HerdrDesktopPet.app"]
    run "/usr/bin/codesign", args: ["--verify", "--deep", "--strict", "{{libexec}}/HerdrDesktopPet.app"]
  end

  def caveats
    <<~EOS
      Start manually with: herdr-desktop-pet start
      This installs only the app and CLI under Homebrew's prefix (not /Applications).
      It does not install the Herdr plugin; for that run:
        herdr plugin install hanbong5938/herdr-desktop-pet
      Tern requires its separate plugin:
        tern plugin install https://github.com/hanbong5938/tern-desktop-pet
      Start an independent Tern profile with:
        herdr-desktop-pet --host tern --config-dir ~/.config/herdr/plugins/config/desktop-pet-tern --state-dir ~/.local/state/herdr/plugins/desktop-pet-tern start
      Configure desktop pet connection in Tern using this CLI and the same paths.
      Plugin installation alone does not install or start the native app.
      It does not install a patched Herdr host either.
      Client-attach auto-start requires the supplied Herdr 0.9.3 host patch.
      The app is ad-hoc signed, not Developer ID signed or notarized.
      Migrating from the old cask? Remove it first:
        brew uninstall --cask herdr-desktop-pet
    EOS
  end

  test do
    # Pack validation initializes AppKit, which aborts in `brew test`'s session.
    assert_equal "herdr-desktop-pet #{version}", shell_output("#{bin}/herdr-desktop-pet --version").strip
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", libexec/"HerdrDesktopPet.app"
  end
end
