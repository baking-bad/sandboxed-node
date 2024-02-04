from pathlib import Path
import requests
from os import environ as env
import subprocess

def run(*args, **kwargs):
    print(f"$ {' '.join(args)}")
    subprocess.run(args, check=True, **kwargs)
    

OCTEZ_REPO_URL = 'https://github.com/serokell/tezos-packaging/releases/latest'


def main():

    version_file = Path('octez_version')
    current_version = version_file.read_text().strip() if version_file.exists() else ''
    print(f'Current version: {current_version}')
    latest_version = requests.get(OCTEZ_REPO_URL).url.split("/")[-1]
    print(f'Latest version:  {latest_version}')

    if current_version == latest_version:
        return

    if not env.get("GITHUB_ACTIONS"):
        print("This script is intended to be run in a GitHub Action.")
        exit(1)

    print('Octez version has changed. Updating...')
    Path('octez_version').write_text(latest_version)

    run('make', 'build')
    run('git', 'checkout', '-b', f'octez-{latest_version}')
    run('git', 'add', 'octez_version')
    run('git', 'commit', '-m', f'Update Octez binaries to {latest_version}')
    run('git', 'push', 'origin', f'octez-{latest_version}')
    run('gh', 'pr', 'create', '-f', '-B', f'octez-{latest_version}', '-t', f'Update Octez binaries to {latest_version}')


if __name__ == "__main__":
    main()