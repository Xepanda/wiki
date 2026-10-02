"""Tests for DNS switching; no root access or live resolver changes."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[2] / 'static/downloads/taishanpi/network-dns-switch.py'
SPEC = importlib.util.spec_from_file_location('dns_switch', SOURCE)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class DNSSwitchTests(unittest.TestCase):
    def test_home_dns_is_preferred_when_it_returns_expected_fake_ip(self):
        self.assertEqual(
            MODULE.choose_policy('198.18.0.19\n', '192.168.183.2\n'),
            ('home', ['192.168.31.2#7874']),
        )

    def test_leaving_home_uses_current_dhcp_dns(self):
        self.assertEqual(
            MODULE.choose_policy('', '192.168.183.2\n'),
            ('away', ['192.168.183.2']),
        )

    def test_unrelated_dns_response_does_not_select_home(self):
        self.assertEqual(
            MODULE.choose_policy('100.64.4.62\n', '10.0.0.1\n'),
            ('away', ['10.0.0.1']),
        )

    def test_no_valid_dhcp_dns_preserves_existing_configuration(self):
        self.assertIsNone(MODULE.choose_policy('', '127.0.0.1\n192.168.31.2\ninvalid\n'))

    def test_fallback_filters_duplicates_loopback_and_invalid_addresses(self):
        self.assertEqual(
            MODULE.choose_policy('', '127.0.0.53\n0.0.0.0\n192.168.183.2\n192.168.183.2\n224.0.0.1\n'),
            ('away', ['192.168.183.2']),
        )

    def test_changed_configuration_restarts_resolver_once(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'upstream.conf'
            path.write_text('server=192.168.31.2#7874\n')
            calls = []
            MODULE.apply_configuration(path, 'server=192.168.183.2\n', lambda: calls.append(1))
            self.assertEqual(path.read_text(), 'server=192.168.183.2\n')
            self.assertEqual(calls, [1])

    def test_same_configuration_does_not_interrupt_dns(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'upstream.conf'
            path.write_text('server=192.168.183.2\n')
            calls = []
            MODULE.apply_configuration(path, 'server=192.168.183.2\n', lambda: calls.append(1))
            self.assertEqual(calls, [])

    def test_failed_restart_restores_previous_upstream(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'upstream.conf'
            path.write_text('server=192.168.31.2#7874\n')
            calls = []

            def restart():
                calls.append(1)
                if len(calls) == 1:
                    raise RuntimeError('resolver start failed')

            with self.assertRaises(RuntimeError):
                MODULE.apply_configuration(path, 'server=192.168.183.2\n', restart)
            self.assertEqual(path.read_text(), 'server=192.168.31.2#7874\n')
            self.assertEqual(calls, [1, 1])

    def test_prepare_writes_upstream_without_restarting(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'upstream.conf'
            MODULE.apply_configuration(path, 'server=192.168.183.2\n', None)
            self.assertEqual(path.read_text(), 'server=192.168.183.2\n')


if __name__ == '__main__':
    unittest.main()
