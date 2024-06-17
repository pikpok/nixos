# NixOS configuration

This repo contains my NixOS setup. This configuration uses [Nix Flakes](https://nixos.wiki/wiki/Flakes).

In hosts you can find configuration for three hosts:

- `mbp`: 2021 Macbook Pro, running macOS with nix-darwin
- `mbp-asahi`: Same 2021 Macbook Pro, running NixOS with [Asahi Linux](https://github.com/AsahiLinux/linux) kernel, using [nixos-m1](https://github.com/tpwrules/nixos-m1)
- `domino`: Home server/NAS built on [X86-P5 mini PC with NVMe expansion card](https://cwwk.net/products/x86-p5-development-version-special-machine-4-m-2-nvme-adapter-board-only-applicable-to-cwwk-x86-p5-n100-i3-n305-model-%E7%9A%84%E5%89%AF%E6%9C%AC?variant=45768260747496)
