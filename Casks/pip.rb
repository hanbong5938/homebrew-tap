cask "pip" do
  version "1.0.0-preview.3"
  sha256 "6c1694bf213d6055269297c349471f3d2218292fb6043836f005bac79fb5231d"

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
