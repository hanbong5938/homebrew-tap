class HerdrDesktopPet < Formula
  desc "Bounded legacy migration bridge to the independent Desktop Pet app"
  homepage "https://github.com/hanbong5938/desktop-pet/blob/main/docs/migrations/desktop-pet.md"
  url "https://github.com/hanbong5938/herdr-desktop-pet/releases/download/v0.3.12/HerdrDesktopPet-v0.3.12-macos-arm64.tar.gz"
  sha256 "c4cecaaf5f5c8dfba26f4c2f384db5c626d3d0d8486bcbc132cbeabae576778d"
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
      Legacy migration bridge only: 0.3.12 / protocol 3 / observation capability 1.
      New installations should use: brew install hanbong5938/tap/desktop-pet
      Existing users obtain the bridge through their actual owner with explicit consent.
      Validated terminal protocol-2 history is read-only; never replay Unknown.
      In the running bridge, approve the separate native migration to Desktop Pet 0.4.8.
      Preserve the exact config/state paths; do not merge unrelated profiles.
      Legacy retirement occurs only after the verified neutral image is ready.
      User Stop suppresses restart; Unknown outcomes are never automatically replayed.
      Protocol-2 beta users must use their retained helper, Stop and back up,
      then explicitly install the frozen pinned v0.3.6 pair before A-to-B.
      This moving formula is not the frozen v0.3.6 installer; beta stays unchanged.
      Default Herdr plugin installation uses integration-only main, not this tag.
      Optional Herdr/Tern integrations do not own or remove the shared app.
      The app is ad-hoc signed, not Developer ID signed or notarized.
      Procedure: https://github.com/hanbong5938/desktop-pet/blob/main/docs/migrations/desktop-pet.md
    EOS
  end

  test do
    # Pack validation initializes AppKit, which aborts in `brew test`'s session.
    assert_equal "herdr-desktop-pet #{version}", shell_output("#{bin}/herdr-desktop-pet --version").strip
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", libexec/"HerdrDesktopPet.app"
  end
end
