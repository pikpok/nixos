# Hermes on Domino

[Hermes Agent](https://hermes-agent.nousresearch.com) in a Podman container,
reached through [@mrxlovelybot](https://t.me/mrxlovelybot) (private chat, owner
only). It uses the ChatGPT subscription via the `openai-codex` provider. All
state lives in `/var/lib/hermes` (backed up by Borgmatic); `SOUL.md` and the
settings in `../hermes.nix` are mounted read-only.

## Bot Screen

Hermes has its own Xfce desktop with regular Google Chrome (nixpkgs, mounted
from `/nix/store`), uBlock Origin Lite and Consent-O-Matic (Chrome policy), and a
persistent profile in `/var/lib/hermes/bot-desktop/browser-profile`. It starts on
the first browser use. To watch it or take over for logins, add
`https://hermes.pikpok.xyz` as a remote gateway in Hermes Desktop, then
**Bots → Hermes → Open Screen**.

Hermes reads `browser.*` only from its writable profile, so these were set once
with `hermes config set` (in `/var/lib/hermes/config.yaml`): `backend: "off"`
(built-in browser tools instead of the browser-use CLI), `headed: true`,
`allow_private_urls: true`. `cua-driver` and `agent-browser` were installed with
`hermes pm install` into `/var/lib/hermes/tools`.

## Driving the Mac

Inside the container `ssh mac` is a full shell as `pikpok` on the Mac (key
authorized from Domino only in `../../mbp/default.nix`), used e.g. for the `orca`
CLI. The `mac` MCP server runs `cua-driver mcp` over the same connection to
drive the desktop. Hermes's key is `/var/lib/hermes/.ssh/id_mac`
(`mac-key.pub`); the Mac's host key is pinned in `mac-known-hosts`.

One-time setup on the Mac: enable Remote Login, `darwin-rebuild switch`, then
`cua-driver permissions grant`. The Mac must be awake and logged in; send
`/reload-mcp` in Telegram after it was offline.

## Operations

```sh
nixos-rebuild switch --flake .#domino \
  --build-host root@192.168.100.7 --target-host root@192.168.100.7
ssh root@192.168.100.7 'podman logs --tail=80 hermes'

# Re-login to ChatGPT, then restart podman-hermes
ssh -t root@192.168.100.7 \
  'podman exec -it -u hermes hermes hermes auth add openai-codex'
```

Dashboard: https://hermes.pikpok.xyz (login in SOPS).

Secrets: `sops secrets/domino/hermes.env`.
