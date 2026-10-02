#!/usr/bin/python3
"""Switch ordinary DNS upstreams while leaving corporate routing to dnsmasq."""
import argparse
import fcntl
import ipaddress
import json
import os
from pathlib import Path
import subprocess
import tempfile


def ipv4_answers(text):
    addresses = []
    for line in text.splitlines():
        try:
            address = ipaddress.IPv4Address(line.strip())
        except ipaddress.AddressValueError:
            continue
        if address not in addresses:
            addresses.append(address)
    return addresses


def choose_policy(home_answers, fallback_answers, home_server='192.168.31.2', home_port=7874):
    # This deployment expects Google's home DNS answer in Mihomo's fake-IP range.
    if any(address in ipaddress.IPv4Network('198.18.0.0/16')
           for address in ipv4_answers(home_answers)):
        return 'home', [f'{home_server}#{home_port}']
    servers = [str(address) for address in ipv4_answers(fallback_answers)
               if not (address.is_loopback or address.is_unspecified
                       or address.is_multicast or address.is_reserved
                       or str(address) == home_server)]
    return ('away', servers) if servers else None


def atomic_write(path, content):
    descriptor, temporary = tempfile.mkstemp(prefix=path.name + '.', dir=path.parent)
    try:
        with os.fdopen(descriptor, 'w') as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, 0o644)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def apply_configuration(path, content, restart):
    previous = path.read_text() if path.exists() else None
    if previous == content:
        return False
    atomic_write(path, content)
    if restart is not None:
        try:
            restart()
        except Exception:
            if previous is None:
                path.unlink()
            else:
                atomic_write(path, previous)
            restart()
            raise
    return True


def output(command, timeout):
    try:
        result = subprocess.run(command, text=True, capture_output=True, timeout=timeout)
        return result.stdout if result.returncode == 0 else ''
    except (subprocess.TimeoutExpired, OSError):
        return ''


def restart_resolver():
    subprocess.run(['/usr/sbin/dnsmasq', '--test',
                    '--conf-file=/etc/dnsmasq-softrouter.conf'], check=True,
                   capture_output=True, text=True, timeout=5)
    subprocess.run(['/usr/bin/systemctl', 'restart', 'dnsmasq-softrouter.service'],
                   check=True, capture_output=True, text=True, timeout=20)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--interface', default='ens33')
    parser.add_argument('--home-server', default='192.168.31.2', type=ipaddress.IPv4Address)
    parser.add_argument('--home-port', default=7874, type=int)
    parser.add_argument('--output', type=Path,
                        default=Path('/etc/dnsmasq-softrouter-upstream.conf'))
    parser.add_argument('--dry-run', action='store_true', help='Report selection without writing')
    parser.add_argument('--prepare', action='store_true', help='Write upstream without restarting DNS')
    args = parser.parse_args()
    if not 1 <= args.home_port <= 65535:
        parser.error('home port must be between 1 and 65535')
    if not args.dry_run and args.output == Path('/etc/dnsmasq-softrouter-upstream.conf') and os.geteuid() != 0:
        parser.error('system configuration requires root; use --dry-run to inspect')
    home = output(['/usr/bin/dig', '@' + str(args.home_server), '-p', str(args.home_port),
                   'www.google.com', 'A', '+short', '+time=1', '+tries=1'], 3)
    dhcp = output(['/usr/bin/nmcli', '-g', 'IP4.DNS', 'device', 'show', args.interface], 4)
    policy = choose_policy(home, dhcp, str(args.home_server), args.home_port)
    if policy is None:
        print(json.dumps({'mode': 'unchanged', 'reason': 'No usable upstream; retain previous configuration'}))
        return
    mode, servers = policy
    content = ''.join(f'server={server}\n' for server in servers)
    if args.dry_run:
        print(json.dumps({'mode': mode, 'servers': servers}))
        return
    # Serialize concurrent timer/manual invocations. The resolver has no hook back to this lock.
    lock_path = args.output.with_suffix(args.output.suffix + '.lock')
    with lock_path.open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        changed = apply_configuration(args.output, content, None if args.prepare else restart_resolver)
    if changed or args.prepare:
        print(json.dumps({'mode': mode, 'servers': servers, 'changed': changed}))


if __name__ == '__main__':
    main()
