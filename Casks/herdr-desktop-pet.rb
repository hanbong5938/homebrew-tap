cask "herdr-desktop-pet" do
  version "0.1.6"
  sha256 "0bcd05cfb4fa386fa8fd4a637f164ef03d1ee265eec171b997277214783e1d03"

  url "https://github.com/hanbong5938/herdr-desktop-pet/releases/download/v#{version}/HerdrDesktopPet-v#{version}-macos-arm64.tar.gz"
  name "Herdr Desktop Pet"
  desc "Native desktop companion for Herdr with session activity and agent messaging"
  homepage "https://github.com/hanbong5938/herdr-desktop-pet"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "HerdrDesktopPet.app"
  binary "#{appdir}/HerdrDesktopPet.app/Contents/MacOS/herdr-desktop-pet"

  uninstall quit: "dev.herdr.desktop-pet"

  caveats <<~EOS
    Start manually with: herdr-desktop-pet start
    This installs the app and CLI, not the Herdr plugin or a patched Herdr host.
    Client-attach auto-start requires the supplied Herdr 0.9.3 host patch.
    The app is ad-hoc signed, not Developer ID signed or notarized.
    If macOS blocks it, review Privacy & Security settings to allow opening it.
  EOS
end
