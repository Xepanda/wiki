#!/usr/bin/python3
"""Install or roll back DNS roaming for this VMware Ubuntu deployment."""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import pwd
import shutil
import subprocess
import sys
import time

MAIN = Path('/etc/dnsmasq-softrouter.conf')
UPSTREAM = Path('/etc/dnsmasq-softrouter-upstream.conf')
HELPER = Path('/usr/local/sbin/network-dns-switch')
SERVICE = Path('/etc/systemd/system/network-dns-switch.service')
TIMER = Path('/etc/systemd/system/network-dns-switch.timer')
FILES = [MAIN, UPSTREAM, HELPER, SERVICE, TIMER]
TIMER_NAME = 'network-dns-switch.timer'
LOG = (Path(pwd.getpwuid(int(os.environ.get('SUDO_UID', os.getuid()))).pw_dir)
       / '.codex/network-roaming-20261002/install-result.log')


def run(command, timeout=30, check=True):
    result = subprocess.run(command, text=True, capture_output=True, timeout=timeout)
    if check and result.returncode:
        raise RuntimeError(f'{command[0]} failed: {result.stderr.strip() or result.stdout.strip()}')
    return result


def timer_state():
    return {key: run(['systemctl', 'is-' + key, TIMER_NAME], check=False).stdout.strip()
            for key in ['enabled', 'active']}


def backup_configuration():
    directory = Path('/root/network-roaming-backup-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    directory.mkdir(mode=0o700)
    manifest = {'timer': timer_state(), 'files': {}}
    for index, path in enumerate(FILES):
        name = str(index)
        manifest['files'][str(path)] = name if path.exists() else None
        if path.exists():
            shutil.copy2(path, directory / name)
    (directory / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return directory


def rollback(directory):
    manifest = json.loads((directory / 'manifest.json').read_text())
    if set(manifest['files']) != {str(path) for path in FILES}:
        raise RuntimeError('Unexpected rollback manifest paths')
    run(['systemctl', 'disable', '--now', TIMER_NAME], check=False)
    # Wait for a running checker to finish before restoring files.
    run(['systemctl', 'stop', 'network-dns-switch.service'], check=False)
    for path in FILES:
        saved = manifest['files'][str(path)]
        if saved is None:
            path.unlink(missing_ok=True)
        else:
            shutil.copy2(directory / saved, path)
    run(['systemctl', 'daemon-reload'])
    run(['dnsmasq', '--test', '--conf-file=' + str(MAIN)])
    run(['systemctl', 'restart', 'dnsmasq-softrouter.service'])
    if manifest['timer']['enabled'] == 'enabled':
        run(['systemctl', 'enable', TIMER_NAME])
    if manifest['timer']['active'] == 'active':
        run(['systemctl', 'start', TIMER_NAME])
    print('Restored configuration from:', directory)


def wait_for_company_dns():
    for _ in range(30):
        result = run(['dig', '@127.0.0.1', 'login-cn.tuya-inc.com', 'A',
                      '+short', '+time=1', '+tries=1'], timeout=3, check=False)
        if result.returncode == 0 and any(
                line.startswith(('100.64.', '100.65.')) for line in result.stdout.splitlines()):
            return result.stdout
        time.sleep(0.2)
    raise RuntimeError('Company DNS did not become ready; check YunShu login/tunnel')


def verify():
    answers = wait_for_company_dns()
    print('Company DNS:', answers.strip())
    for label, url in [('Company login', 'https://cowork-cn.tuya-inc.com:7799/'),
                       ('Ordinary internet', 'https://www.google.com/')]:
        result = run(['curl', '--noproxy', '*', '-sS', '-L', '--max-redirs', '8',
                      '--connect-timeout', '5', '--max-time', '25', '-o', '/dev/null',
                      '-w', '%{http_code} %{ssl_verify_result}', url], timeout=30)
        print(label + ': HTTP/TLS ' + result.stdout)
        if result.stdout.strip() != '200 0':
            raise RuntimeError(label + ' verification failed')
    print(run(['systemctl', 'is-active', 'dnsmasq-softrouter.service']).stdout.strip())
    print('Current ordinary upstream:', UPSTREAM.read_text().strip())
    print('Tailscale compatibility rule preserved:')
    result = run(['iptables', '-S', 'INPUT'])
    rules = [line for line in result.stdout.splitlines() if 'yunshu-tailscale-compat' in line]
    if not rules:
        raise RuntimeError('Expected existing Tailscale compatibility rule is missing')
    print('\n'.join(rules))


def install():
    source = Path(__file__).resolve().parent
    for filename in ['network-dns-switch.py', SERVICE.name, TIMER.name]:
        if not (source / filename).is_file():
            raise RuntimeError('Missing installer companion: ' + filename)
    text = MAIN.read_text()
    if 'server=/tuya-inc.com/10.251.1.1' not in text.splitlines():
        raise RuntimeError('Expected existing company DNS rule is missing; refusing to replace configuration')
    if not any(line == 'server=192.168.31.2#7874' or line == 'conf-file=' + str(UPSTREAM)
               for line in text.splitlines()):
        raise RuntimeError('Unexpected ordinary DNS configuration')
    # Determine a usable upstream before changing anything.
    selection = json.loads(run(['python3', str(source / 'network-dns-switch.py'), '--dry-run']).stdout)
    if selection['mode'] != 'home':
        raise RuntimeError('Run this initial installation at home with YunShu connected')
    directory = backup_configuration()
    print('Backup:', directory, flush=True)
    try:
        run(['systemctl', 'stop', TIMER_NAME], check=False)
        run(['systemctl', 'stop', 'network-dns-switch.service'], check=False)
        shutil.copyfile(source / 'network-dns-switch.py', HELPER)
        HELPER.chmod(0o755)
        for target in [SERVICE, TIMER]:
            shutil.copyfile(source / target.name, target)
            target.chmod(0o644)
        run([str(HELPER), '--prepare'])
        lines = [line for line in text.splitlines()
                 if line not in ['server=192.168.31.2#7874', 'conf-file=' + str(UPSTREAM)]]
        lines.append('conf-file=' + str(UPSTREAM))
        MAIN.write_text('\n'.join(lines) + '\n')
        run(['dnsmasq', '--test', '--conf-file=' + str(MAIN)])
        run(['systemctl', 'daemon-reload'])
        run(['systemctl', 'restart', 'dnsmasq-softrouter.service'])
        verify()
        run(['systemctl', 'enable', '--now', TIMER_NAME])
        print('Timer:', run(['systemctl', 'is-active', TIMER_NAME]).stdout.strip())
        print('INSTALLATION VERIFIED')
        print('Rollback command: sudo python3 ' + str(source / Path(__file__).name)
              + ' --rollback ' + str(directory))
    except BaseException:
        rollback(directory)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--rollback', type=Path)
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    if os.geteuid() != 0:
        parser.error('Use sudo; authentication stays in your local terminal')
    if args.rollback:
        rollback(args.rollback)
        return
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open('w', buffering=1) as stream:
        LOG.chmod(0o644)
        # Only DNS, service state and verification status are logged.
        original_stdout, original_stderr = sys.stdout, sys.stderr
        sys.stdout = sys.stderr = stream
        try:
            verify() if args.verify else install()
        except Exception as error:
            print('FAILED:', error)
            raise SystemExit(1)
        finally:
            sys.stdout, sys.stderr = original_stdout, original_stderr
            print('Result saved:', LOG)


if __name__ == '__main__':
    main()
