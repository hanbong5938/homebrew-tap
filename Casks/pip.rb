cask "pip" do
  version "1.0.0-preview.1"
  sha256 "fa7eb1c6df5073c18be8539d4255c5e06f3d2837d01fb88e98da30bbcd6e623e"

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
