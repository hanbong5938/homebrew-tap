class HerdrDesktopPetBeta < Formula
  desc "Native Herdr desktop companion with session activity and agent messaging (beta)"
  homepage "https://github.com/hanbong5938/herdr-desktop-pet"
  url "https://github.com/hanbong5938/herdr-desktop-pet/releases/download/beta/0.3.0-beta.2/HerdrDesktopPet-v0.3.0-beta.2-macos-arm64.tar.gz"
  sha256 "58b6473e14ded7e68da577582025edb4ff5ce87bd2be068b783e8d0c1727c781"
  # Software is MIT; bundled artwork is not MIT-licensed.
  license :cannot_represent

  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    # Homebrew stages the single top-level app directory by changing into it.
    (libexec/"HerdrDesktopPetBeta.app").install "Contents"
    # Keep the native executable's resource-relative path inside the bundle.
    bin.write_exec_script libexec/"HerdrDesktopPetBeta.app/Contents/MacOS/herdr-desktop-pet"
    (bin/"herdr-desktop-pet").rename(bin/"herdr-desktop-pet-beta")
  end

  post_install_steps do
    # Keg relocation can break the ad-hoc bundle seal; re-sign inner-to-outer.
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPetBeta.app/Contents/Frameworks/libherdr_rig.dylib"],
        writable_paths: ["{{libexec}}/HerdrDesktopPetBeta.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPetBeta.app/Contents/MacOS/rig-decode-worker"],
        writable_paths: ["{{libexec}}/HerdrDesktopPetBeta.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/HerdrDesktopPetBeta.app/Contents/MacOS/herdr-desktop-pet"],
        writable_paths: ["{{libexec}}/HerdrDesktopPetBeta.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-", "{{libexec}}/HerdrDesktopPetBeta.app"],
        writable_paths: ["{{libexec}}/HerdrDesktopPetBeta.app"]
    run "/usr/bin/codesign", args: ["--verify", "--deep", "--strict", "{{libexec}}/HerdrDesktopPetBeta.app"]
  end

  def caveats
    <<~EOS
      Start manually with: herdr-desktop-pet-beta start
      Stop with: herdr-desktop-pet-beta stop
      Back up your profile and quit the stable app before starting the beta.
      Stable and beta share a profile and control namespace; do not run both
      simultaneously without isolating both their configuration and state.
      This installs only the beta app and CLI, not the Herdr plugin or a patched host.
      The app is ad-hoc signed, not Developer ID signed or notarized.
      Physical GUI behavior has not been checked; try it in a disposable checkout.
    EOS
  end

  test do
    # Pack validation initializes AppKit, which aborts in `brew test`'s session.
    assert_equal "herdr-desktop-pet #{version}", shell_output("#{bin}/herdr-desktop-pet-beta --version").strip
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", libexec/"HerdrDesktopPetBeta.app"
  end
end
