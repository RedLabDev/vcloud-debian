# Prepare Debian vApp

1. Dwonload and install latest ovftool (requires free registration)
https://code.vmware.com/web/tool/4.4.0/ovf

2. Install qemu (qemu-img)

3. Install vcd-cli (http://vmware.github.io/vcd-cli/install.html)
`pip3 install --user vcd-cli`

4. Login
`vcd login --no-verify-ssl-certs [API_host] [org] [username]`
