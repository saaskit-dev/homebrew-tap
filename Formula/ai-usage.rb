# typed: false
# frozen_string_literal: true

class AiUsage < Formula
  homepage "https://github.com/saaskit-dev/ai-usage"
  version "v0.0.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/saaskit-dev/ai-usage/releases/download/#{version}/ai-usage-macos-arm64.tar.gz"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    end
    on_intel do
      url "https://github.com/saaskit-dev/ai-usage/releases/download/#{version}/ai-usage-macos-amd64.tar.gz"
      sha256 "5d0bd26f7b1f66bbfcffa966ad6dee26a6d962f1f2cb736d42ac4a60b978f6eb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/saaskit-dev/ai-usage/releases/download/#{version}/ai-usage-linux-arm64.tar.gz"
      sha256 "8d33d532c03d7dfd0741f6ea29dc035fb53b2b1fe6990612e8f07fd7bee3c6a1"
    end
    on_intel do
      url "https://github.com/saaskit-dev/ai-usage/releases/download/#{version}/ai-usage-linux-amd64.tar.gz"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    end
  end

  def install
    bin.install "ai-usage"
    etc.install "config.example.yaml" => "ai-usage.example.yaml"
    (var/"ai-usage").mkpath
  end

  def post_install
    config_path = HOMEBREW_PREFIX/"etc/ai-usage.yaml"
    unless config_path.exist?
      cp etc/"ai-usage.example.yaml", config_path
      ohai "Created default config at #{config_path}"
    end
  end

  def caveats
    <<~EOS
      Configuration file created at:
        #{HOMEBREW_PREFIX}/etc/ai-usage.yaml

      To enable auto-start on macOS:
        ai-usage daemon install

      To enable auto-start on Linux:
        sudo ai-usage daemon install

      Or for user-level service (Linux):
        ai-usage daemon install --user

      Sample configuration at:
        #{HOMEBREW_PREFIX}/etc/ai-usage.example.yaml
    EOS
  end

  service do
    run [bin/"ai-usage"]
    keep_alive true
    log_path var/"log/ai-usage.log"
    error_log_path var/"log/ai-usage.error.log"
  end

  test do
    assert_version_match version, shell_output("#{bin}/ai-usage --version").strip
  end
end
