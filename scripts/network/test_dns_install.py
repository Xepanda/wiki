"""Installer readiness and rollback tests without live system changes."""
import importlib.util
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[2] / 'static/downloads/taishanpi/install-network-dns-switch.py'
SPEC = importlib.util.spec_from_file_location('dns_install', SOURCE)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class InstallerTests(unittest.TestCase):
    def test_dns_restart_waits_past_initial_connection_refusal(self):
        answers = [
            SimpleNamespace(returncode=9, stdout='connection refused'),
            SimpleNamespace(returncode=0, stdout='100.64.0.45\n'),
        ]
        with patch.object(MODULE, 'run', side_effect=answers), patch.object(MODULE.time, 'sleep'):
            self.assertEqual(MODULE.wait_for_company_dns(), '100.64.0.45\n')

    def test_dns_readiness_stops_after_bounded_attempts(self):
        response = SimpleNamespace(returncode=9, stdout='connection refused')
        with patch.object(MODULE, 'run', return_value=response) as query, patch.object(MODULE.time, 'sleep'):
            with self.assertRaises(RuntimeError):
                MODULE.wait_for_company_dns()
            self.assertEqual(query.call_count, 30)

    def test_rollback_restores_existing_files_and_removes_new_files(self):
        import json
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            paths = [root / name for name in ['main', 'upstream', 'helper', 'service', 'timer']]
            paths[0].write_text('original company and home DNS')
            paths[2].write_text('previous helper')
            backup = root / 'backup'
            backup.mkdir()
            manifest = {'timer': {'enabled': 'disabled', 'active': 'inactive'}, 'files': {}}
            for index, path in enumerate(paths):
                name = str(index) if path.exists() else None
                manifest['files'][str(path)] = name
                if name is not None:
                    (backup / name).write_text(path.read_text())
                path.write_text('new installation')
            (backup / 'manifest.json').write_text(json.dumps(manifest))
            commands = []

            def run(command, **kwargs):
                commands.append(command)
                return SimpleNamespace(stdout='', returncode=0)

            with patch.object(MODULE, 'FILES', paths), patch.object(MODULE, 'MAIN', paths[0]), patch.object(MODULE, 'run', run):
                MODULE.rollback(backup)
            self.assertEqual(paths[0].read_text(), 'original company and home DNS')
            self.assertEqual(paths[2].read_text(), 'previous helper')
            self.assertFalse(paths[1].exists())
            self.assertFalse(paths[3].exists())
            self.assertFalse(paths[4].exists())
            self.assertIn(['systemctl', 'restart', 'dnsmasq-softrouter.service'], commands)
            self.assertNotIn(['systemctl', 'enable', MODULE.TIMER_NAME], commands)


if __name__ == '__main__':
    unittest.main()
