cask "pip" do
  version "1.0.0-preview.4"
  sha256 "f7f18f74d138c23e55181619c05b6b75d3d5e1759cc47da082d9d63c568de9f1"

  url "https://github.com/hanbong5938/pip/releases/download/v#{version}/PiP-v#{version}-macos-arm64.zip"
  name "PiP"
  desc "Display a selected window in a floating picture-in-picture panel"
  homepage "https://github.com/hanbong5938/pip"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Pip.app"

  uninstall quit: "dev.local.pip"

  caveats <<~EOS
    Requires macOS 15.2 or later and Apple Silicon.
    This experimental build is ad-hoc signed and is not notarized by Apple.
    If macOS blocks it, review Privacy & Security settings to allow opening it.
    Capture can freeze when the source app stops rendering on another desktop.
  EOS
end
