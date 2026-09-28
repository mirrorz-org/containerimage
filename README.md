# containerimage

The fast way to use mirrors.cernet.edu.cn in your container.

## Mirror selection

Debian and Ubuntu (including Ubuntu Ports) use the CERNET APT mirrorlist API
with APT 1.6 or newer. Older APT versions use the CERNET mirror URL directly.
Both traditional sources.list and DEB822 .sources files are supported.
Security updates also use mirrorlist, without the optional official_index parameter.

Fedora and Rocky Linux use the CERNET RPM mirrorlist API. Alpine and Arch Linux
use the CERNET mirror URL directly.

## Available distros

Images are currently published only to GHCR:

`ghcr.io/mirrorz-org/ubuntu`, `ghcr.io/mirrorz-org/debian`, `ghcr.io/mirrorz-org/fedora`,
`ghcr.io/mirrorz-org/rocky`, `ghcr.io/mirrorz-org/alpine`, `ghcr.io/mirrorz-org/archlinux`.

Docker Hub publishing is disabled in the workflow and build scripts.

## Example

```shell
sudo docker run -it --rm ghcr.io/mirrorz-org/debian:13
```

## License

MIT. This project is modified from [ustclug/mirrorimage](https://github.com/ustclug/mirrorimage).
