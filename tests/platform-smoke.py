#!/usr/bin/env python3
"""Exercise installed Boo in an isolated home without touching user settings."""
import os
from pathlib import Path
import platform
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[1]
for custom_xdg in (False, True):
    with tempfile.TemporaryDirectory(prefix="boo-test-") as directory:
        home = Path(directory)
        config_root = home / ("custom config" if custom_xdg else ".config")
        env = dict(os.environ, HOME=str(home), NO_COLOR="1", TERM="dumb",
                   SHELL="/bin/zsh", TERM_PROGRAM="", BOO_NO_AUTO_APPLY="1")
        env.pop("XDG_CONFIG_HOME", None)
        if custom_xdg:
            env["XDG_CONFIG_HOME"] = str(config_root)
        env["PATH"] = str(home / ".local/bin") + os.pathsep + env["PATH"]
        config = config_root / "ghostty/config"
        config.parent.mkdir(parents=True)
        original = "font-family = monospace\nfont-size = 17\nbackground-opacity = 0.83\n"
        config.write_text(original)
        mac_config = home / "Library/Application Support/com.mitchellh.ghostty/config"
        mac_config.parent.mkdir(parents=True)
        mac_config.write_text(original)

        def run(*args, **overrides):
            result = subprocess.run(args, cwd=repo, env=dict(env, **overrides),
                                    text=True, capture_output=True)
            assert result.returncode == 0, (args, result.stdout, result.stderr)
            return result.stdout

        run("bash", "scripts/install.sh")
        boo = str(home / ".local/bin/boo")
        assert "font-size = 17" in config.read_text()
        assert "background-opacity = 0.83" in config.read_text()
        if custom_xdg:
            assert not (home / ".config/ghostty/config").exists()
        for theme in (home / ".config/boo/themes").rglob("*.theme"):
            run(boo, "theme", theme.stem)
        run(boo, "theme", "crimson")
        before = config.read_text()
        run("bash", "scripts/install.sh")
        assert config.read_text() == before, "Upgrade changed the saved theme/config"
        run(boo, "doctor")
        run(boo, "opacity", "glass")
        for mode in ("full", "public"):
            run(boo, "mode", mode)
            panel = run("zsh", "-f", "-c",
                        'source "$HOME/.config/boo/boo.zsh"; show_boo_startup_panel')
            assert "MEMORY" in panel, panel
            if platform.system() == "Linux":
                assert "Linux" in panel and "CPU     : -" not in panel, panel
                assert "MEMORY  : -" not in panel, panel
        reload_output = run(boo, "reload", "--unsafe", BOO_NO_AUTO_APPLY="0") if platform.system() == "Linux" else run(boo, "reload", BOO_NO_AUTO_APPLY="0")
        if platform.system() == "Linux":
            assert "Ctrl+Shift+," in reload_output and "Cmd" not in reload_output
            assert "macos-" not in config.read_text()
            assert mac_config.read_text() == original
        else:
            assert "Cmd+Shift+," in reload_output
        run(boo, "uninstall", "--yes")
        assert config.read_text() == original, "Uninstall failed to restore original config"
        assert mac_config.read_text() == original
        assert "# >>> Boo >>>" not in (home / ".zshrc").read_text()
        print(f"Passed {platform.system()} lifecycle (custom XDG: {custom_xdg})")
