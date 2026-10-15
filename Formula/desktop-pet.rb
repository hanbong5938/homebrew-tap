class DesktopPet < Formula
  desc "Shared native desktop companion with optional Herdr and Tern adapters"
  homepage "https://hanbong5938.github.io/desktop-pet/"
  url "https://github.com/hanbong5938/desktop-pet/releases/download/v0.4.7/DesktopPet-v0.4.7-macos-arm64.tar.gz"
  sha256 "f89ea6c52197bd4c7fb70336846099f1e5eb553f2de9bb4cd43b14b1134da8fa"
  # Software is MIT; bundled artwork is not MIT-licensed.
  license :cannot_represent

  depends_on arch: :arm64
  depends_on macos: :ventura

  resource "release-rig-provenance" do
    url "https://github.com/hanbong5938/desktop-pet/releases/download/v0.4.7/DesktopPet-v0.4.7-rig-native.json"
    sha256 "2d28f7be1a5f83e6d0d1cc8bfc96727c0ca7c38546423ca7bb526d434a6b794b"
  end

  def install
    # Homebrew stages the single top-level app directory as Contents.
    (libexec/"DesktopPet.app").install "Contents"
    resource("release-rig-provenance").stage do
      libexec.install "DesktopPet-v0.4.7-rig-native.json" => "DesktopPet.app.release-rig-native.json"
    end
    bin.write_exec_script libexec/"DesktopPet.app/Contents/MacOS/desktop-pet"
  end

  post_install_steps do
    # Preserve the decoder's JIT entitlement and restore the seal after relocation.
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/DesktopPet.app/Contents/Frameworks/libherdr_rig.dylib"],
        writable_paths: ["{{libexec}}/DesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--preserve-metadata=entitlements", "--sign", "-",
                         "{{libexec}}/DesktopPet.app/Contents/MacOS/rig-decode-worker"],
        writable_paths: ["{{libexec}}/DesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/DesktopPet.app/Contents/MacOS/desktop-pet-update-coordinator"],
        writable_paths: ["{{libexec}}/DesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-",
                         "{{libexec}}/DesktopPet.app/Contents/MacOS/desktop-pet"],
        writable_paths: ["{{libexec}}/DesktopPet.app"]
    run "/usr/bin/codesign",
        args:           ["--force", "--timestamp=none", "--sign", "-", "{{libexec}}/DesktopPet.app"],
        writable_paths: ["{{libexec}}/DesktopPet.app"]
    run "/usr/bin/codesign", args: ["--verify", "--deep", "--strict", "{{libexec}}/DesktopPet.app"]
    # Keep the authenticated original record. Only manager re-signing may derive
    # a new deployed hash map; native validation checks Brew receipt/root ownership
    # and rejects changes outside the four signed binaries and bundle seal.
    run "/usr/bin/ruby",
        args: ["-rjson", "-rdigest", "-e", <<~RUBY, "{{libexec}}"],
          root = ARGV.fetch(0)
          original = File.join(root, "DesktopPet.app.release-rig-native.json")
          bytes = File.binread(original)
          record = JSON.parse(bytes)
          raise "invalid original release provenance" if record.key?("signing_derivation")
          contents = File.join(root, "DesktopPet.app", "Contents")
          hashes = record.fetch("deployed_sha256")
          hashes.each_key do |path|
            raise "unsafe release resource path" if path.start_with?("/") || path.split("/").any? { |part| part.empty? || part == "." || part == ".." }
            file = File.join(contents, path)
            raise "nonregular release resource" unless File.file?(file) && !File.symlink?(file)
            hashes[path] = Digest::SHA256.file(file).hexdigest
          end
          record["signing_derivation"] = {
            "kind" => "homebrew_ad_hoc",
            "original_record" => "DesktopPet.app.release-rig-native.json",
            "original_sha256" => Digest::SHA256.hexdigest(bytes),
          }
          File.write(File.join(root, "DesktopPet.app.rig-native.json"), JSON.pretty_generate(record) + "\n")
        RUBY
        writable_paths: ["{{libexec}}"]
  end

  def caveats
    <<~EOS
      Start explicitly with: desktop-pet start
      This installs one shared app and CLI under Homebrew's prefix, not /Applications.
      Optional integrations are installed separately:
        herdr plugin install hanbong5938/herdr-desktop-pet
        tern plugin install https://github.com/hanbong5938/tern-desktop-pet
      Tern Connect/Configure never installs or automatically starts the native app.
      Use desktop-pet profile show --json to inspect the selected config/state pair.
      Integration removal does not remove this app, profiles or characters.
      The app is ad-hoc signed, not Developer ID signed or notarized.
      Existing legacy users must follow the separately consented A-to-B migration;
      installing this neutral formula does not retire an old installation or merge profiles.
    EOS
  end

  test do
    assert_equal "desktop-pet #{version}", shell_output("#{bin}/desktop-pet --version").strip
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", libexec/"DesktopPet.app"
  end
end
