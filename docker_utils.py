# pylint: skip-file


def get_secret(path):
    with open(path, "r") as secret_file:
        return secret_file.read().strip()
