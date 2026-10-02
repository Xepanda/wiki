# DNS roaming validation

Run the focused tests without generating cache files in the downloadable assets:

```bash
python3 -B -m unittest discover -s scripts/network -v
```

The tests use temporary files and replace service commands at the process boundary. They do not modify the system resolver or require root.

The downloadable implementation and installer live in `static/downloads/taishanpi/`. The installation guide is `docs/02-projects/hardware-embedded/taishanpi/11-ubuntu-dns-roaming.mdx`.
