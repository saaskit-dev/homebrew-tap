# typed: false
# frozen_string_literal: true

class AiUsage < Formula
  desc "AI usage tracker for Claude, Copilot, and Cursor"
  homepage "https://github.com/saaskit-dev/ai-usage"
  url "https://github.com/saaskit-dev/ai-usage.git", tag: "v0.0.1"
  license "MIT"
  head "https://github.com/saaskit-dev/ai-usage.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags=-s -w", "-o", bin/"ai-usage", "./cmd/ai-usage"
    (etc/"ai-usage.yaml").write example_config unless (etc/"ai-usage.yaml").exist?
    (var/"ai-usage").mkpath
    (var/"log").mkpath
  end

  def post_install
    # 启动服务
    system "brew", "services", "start", "ai-usage"
  end

  def example_config
    <<~YAML
      # AI Usage Monitor Configuration
      # Default: only Claude enabled, port 18000, interval 5min

      server:
        addr: ":18000"

      monitor:
        interval: "300s"

      notify:
        # apprise_urls:
        #   - "schan://your-sendkey"
        rules:
          - event: depleted
          - event: probe_error

      providers:
        claude:
          enabled: true
          # paths:
          #   - ~/.claude-work/
        copilot:
          enabled: false
          # token: ghp_xxx
        cursor:
          enabled: false
          # token: xxx
    YAML
  end

  def caveats
    <<~EOS
      Configuration: #{etc}/ai-usage.yaml
      Log:           #{var}/log/ai-usage.log
      Data:          #{var}/ai-usage/usage.json

      Commands:
        ai-usage          Start daemon (foreground)
        ai-usage status   Show status and paths

      Manage with brew services:
        brew services start ai-usage
        brew services stop ai-usage
        brew services restart ai-usage
    EOS
  end

  service do
    run [bin/"ai-usage"]
    keep_alive true
    log_path var/"log/ai-usage.log"
    error_log_path var/"log/ai-usage.error.log"
  end

  test do
    assert_match "AI usage monitoring daemon", shell_output("#{bin}/ai-usage --help")
  end
end
