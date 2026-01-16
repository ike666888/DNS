Markdown

# 🌐 Linux Universal DNS Changer (一键 DNS 修改脚本)

这是一个轻量级、智能化的 Linux DNS 修改脚本。它可以自动检测系统环境，将系统的 DNS 服务器永久修改为 **Google (8.8.8.8)** 和 **Cloudflare (1.1.1.1)**，并自动防止 DHCP 覆盖配置。

## 🚀 快速使用 (Quick Start)

无需下载文件，直接在服务器终端执行以下命令即可：

```bash
curl -fsSL https://raw.githubusercontent.com/ike666888/DNS/main/dns.sh | sudo bash
```
✨ 功能特点 (Features)
⚡️ 极速配置： 一键将 DNS 设置为全球最快的 8.8.8.8 和 1.1.1.1。

🧠 智能识别：

自动识别 Debian 11/12 / Ubuntu 等使用 systemd-resolved 的现代系统，修改全局配置并强制通过 Domains=~. 优先解析。

自动识别 CentOS / Alpine 等传统系统，修改 /etc/resolv.conf。

🔒 防覆盖机制： 对于传统系统，自动使用 chattr +i 锁定文件，防止重启后被云服务商的 DHCP 还原。

👀 幂等性检测： 脚本运行前会自动检查当前 DNS，如果已经是 8.8.8.8，则自动跳过，避免重复重启服务。

🌍 全平台支持： 支持 Debian, Ubuntu, CentOS, Alpine, Fedora, Rocky Linux 等主流 Linux 发行版。

🛠️ 验证修改 (Verification)
脚本执行完毕后，你可以通过以下命令查看当前生效的 DNS：

Bash

cat /etc/resolv.conf
预期输出： 你应该能看到 nameserver 8.8.8.8 排在第一行。

Plaintext

nameserver 8.8.8.8
nameserver 1.1.1.1
...
📝 脚本逻辑 (How it works)
检查 Root 权限：确保有足够权限修改系统文件。

环境检测：

如果检测到 systemd-resolved 运行中，修改 /etc/systemd/resolved.conf。

如果未检测到，修改 /etc/resolv.conf 并加锁。

应用变更：重启网络服务或 DNS 服务使配置生效。

连通性测试：Ping google.com 验证网络是否正常。

⚠️ 免责声明
本脚本主要用于服务器网络环境优化。虽然经过多次测试，但在生产环境使用前，建议先备份重要配置。
