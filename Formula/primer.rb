# Homebrew formula for Primer CLI
# 
# To install locally for testing:
#   brew install --build-from-source ./Formula/primer.rb
#
# To tap and install (once published):
#   brew tap your-username/primer
#   brew install primer

class Primer < Formula
  desc "A composable, idempotent project bootstrapping system"
  homepage "https://github.com/jameymcelveen/primer"
  url "https://github.com/jameymcelveen/primer/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "UPDATE_WITH_ACTUAL_SHA256"
  license "MIT"
  head "https://github.com/jameymcelveen/primer.git", branch: "main"

  depends_on "node@18"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/primer --version")
    assert_match "Available Modules", shell_output("#{bin}/primer list")
  end
end
