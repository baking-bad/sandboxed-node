from pathlib import Path
import requests
from os import environ as env
import subprocess

def run(*args, **kwargs):
    print(f"$ {' '.join(args)}")
    subprocess.run(args, check=True, **kwargs)


OCTEZ_RELEASES_API = 'https://gitlab.com/api/v4/projects/tezos%2Ftezos/releases'


def get_latest_octez_version():
    """Fetch latest stable octez-v* release from GitLab (excluding rc/beta/evm/rollup)."""
    releases = requests.get(OCTEZ_RELEASES_API).json()
    for release in releases:
        tag = release['tag_name']
        # Only consider stable octez releases (octez-vX.Y or octez-vX.Y.Z)
        if tag.startswith('octez-v') and '-rc' not in tag and '-beta' not in tag:
            # Convert octez-v24.0 -> v24.0 to match version file format
            return tag.replace('octez-', '')
    return None


def main():
    version_file = Path('octez_version')
    current_version = version_file.read_text().strip() if version_file.exists() else ''
    print(f'Current version: {current_version}')
    latest_version = get_latest_octez_version()
    print(f'Latest version:  {latest_version}')

    if current_version == latest_version:
        print('Octez version is up to date.')
        exit(0)

    if not env.get("GITHUB_ACTIONS"):
        print("This script is intended to be run in a GitHub Action.")
        exit(0)

    print('Octez version has changed. Updating...')
    Path('octez_version').write_text(latest_version)
    exit(1)

if __name__ == "__main__":
    main()