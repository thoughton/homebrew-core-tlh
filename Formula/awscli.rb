class Awscli < Formula
  include Language::Python::Virtualenv

  desc "Official Amazon AWS command-line interface"
  homepage "https://aws.amazon.com/cli/"
  # awscli should only be updated every 10 releases on multiples of 10
  url "https://github.com/aws/aws-cli/archive/1.16.20.tar.gz"
  sha256 "28a2917324dd905e317df4da1a8ea28ecbc17557b5d113bdfbc376f0a6b0db1c"
  head "https://github.com/aws/aws-cli.git", :branch => "develop"

  bottle do
    cellar :any_skip_relocation
    sha256 "9e69b0fe73789d48358bdcc2e675fe1adaddcd2292c1be0bf7d55db5e2111092" => :mojave
    sha256 "fd2356bef1ca832000d29d7f54d315447edce4574909b8be54c77a02ea0cbd41" => :high_sierra
    sha256 "a835604ade46cda28216d81345011ea94127873a70de55128e2e301dba82fc84" => :sierra
    sha256 "cd97646024ff3548c7514ca1dca30f140cdf36a00649d28dbf43ba2aac9aa96f" => :x86_64_linux
  end

  # Some AWS APIs require TLS1.2, which system Python doesn't have before High
  # Sierra
  depends_on "python"

  depends_on "libyaml" unless OS.mac?

  def install
    venv = virtualenv_create(libexec, "python3")
    system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:",
                              "--ignore-installed", buildpath
    system libexec/"bin/pip", "uninstall", "-y", "awscli"
    venv.pip_install_and_link buildpath
    pkgshare.install "awscli/examples"

    rm Dir["#{bin}/{aws.cmd,aws_bash_completer,aws_zsh_completer.sh}"]
    bash_completion.install "bin/aws_bash_completer"
    zsh_completion.install "bin/aws_zsh_completer.sh"
    (zsh_completion/"_aws").write <<~EOS
      #compdef aws
      _aws () {
        local e
        e=$(dirname ${funcsourcetrace[1]%:*})/aws_zsh_completer.sh
        if [[ -f $e ]]; then source $e; fi
      }
    EOS
  end

  def caveats; <<~EOS
    The "examples" directory has been installed to:
      #{HOMEBREW_PREFIX}/share/awscli/examples
  EOS
  end

  test do
    if OS.mac?
      assert_match "topics", shell_output("#{bin}/aws help")
    else
      # aws-cli needs groff as dependency, which we do not want to install
      # just to display the help.
      system "#{bin}/aws", "--version"
    end
  end
end
